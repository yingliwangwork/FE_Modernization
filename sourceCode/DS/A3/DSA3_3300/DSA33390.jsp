<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<!--
程式：DSA33390.jsp
作者：李明翰
功能：社區資料庫維護
完成：

[20230703] 修改呈核檢核規則
-->
<html>
<head>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--匯入外部Javascript 與 css-->

<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/tabs.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/suggest.js'></script><%-- 搜尋提示用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>

<script type='text/javascript'>
<%-- 產生畫面物件 --%>
<%--透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()--%>
Event.observe(window, 'load', new DSA33390().initApp);

function DSA33390(){
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3390/');
	var valid;
	var isQuery = false;
	
	<%-- [20221205]按鈕權限 --%>
	function buttonAuth(){
		var authButtons = {
			B0073:"btnConfirm", <%--呈核 --%>
			B0117:"btnCaptainConfirm", <%--組長覆核 --%>	
			B0018:"btnConfirmReject", <%--組長退回 --%>	
			B0005:"btnDelete" <%--刪除 --%>
		};
		
		<dz:grantButtons FUNC_ID="DSA33390" ignored="false"/>	
	}
	
	<%--畫面檢核--%>
	function initValidation(){
		
		Validation.addAllThese([
        	['validLength10', '長度最多為10', function(v , node) { 
        		return v.length <= 10;
        	}]
        ]);
		
		valid = new Validation('form1', {useTitles:false});		

		valid.define( "required" , { id:"COMMUNITY_NO" , errMsg : "社區編號為必填" } );
		valid.define( "validLength10" , { id:"COMMUNITY_NO", errMsg : "社區編號長度最多為10"} );

	}
	<%--所有分頁內容--%>
	var allTabs = [
		{id:"DSA33310", src:"DSA3_3310", "title":"社區資料"},			      
		{id:"DSA33301", src:"DSA3_3301", "title":"基本資料"},
		{id:"DSA33302", src:"DSA3_3302", "title":"建物列管"},
		{id:"DSA33303", src:"DSA3_3303", "title":"土地資料"},
		{id:"DSA33304", src:"DSA3_3304", "title":"環境資料"},
		{id:"DSA33305", src:"DSA3_3305", "title":"車位資料"},
		{id:"DSA33306", src:"DSA3_3306", "title":"使照資料"},
		//{id:"DSA33307", src:"DSA3_3307", "title":"影像資料"},
		{id:"DSA33309", src:"DSA3_3309", "title":"影像資料"}
	];
	var tabs;
	var buttons = {
		<%--查詢--%>
		doQuery : function(){	
			$('COMMUNITY_NO').value = $('COMMUNITY_NO').value.toUpperCase();	
			valid.reset();
			if(!valid.validate()){
				return;
			}
			ajaxRequest.post('query', 
			{ 
				COMMUNITY_NO : $F('COMMUNITY_NO'),
				UPDATE_TIME : $F('UPDATE_TIME')
			},function(resp){ 
				<%--清除舊的src，避免重查--%>
				$('DSA33310').setAttribute('src', '');
				$('DSA33301').setAttribute('src', '');
				$('DSA33302').setAttribute('src', '');
				$('DSA33303').setAttribute('src', '');
				$('DSA33304').setAttribute('src', '');
				$('DSA33305').setAttribute('src', '');
				$('DSA33306').setAttribute('src', '');
				//$('DSA33307').setAttribute('src', '');
				$('DSA33309').setAttribute('src', '');
				
				<%--[20221205] 修改傳入參數--%>
				actions.createTabs(resp.COMMUNITY_NO, resp.UPDATE_TIME);
				$('COMMUNITY_NO').setValue(resp.COMMUNITY_NO);
				$('UPDATE_TIME').setValue(resp.UPDATE_TIME);
				isQuery = true;
			});			
		},
		
		<%--電子地圖--%>
		doElectronicMap : function(){
			$('COMMUNITY_NO').value = $('COMMUNITY_NO').value.toUpperCase();
			valid.reset();
			if(!valid.validate()){
				return;
			}
			<%--231020023853_承作區_上線前置作業調整--%>
			ajaxRequest.post('electronicMap', {COMMUNITY_NO : $F('COMMUNITY_NO')},
				function(resp){ 
					popupWin.windowOpen('<%=dispatcher%>/DSA3_1900/prompt',{
				    	'windowName': 'DSA3_1900',
		        		'parameters': {'CASE_NO' : $('COMMUNITY_NO').value, 'CASE_TYPE' : 'DSC'},
		        		'fullScreen': true
		    		});
				}
			);		
		},
		<%--[20221205]呈核--%>
		doConfirm : function(){	

			$('COMMUNITY_NO').value = $('COMMUNITY_NO').value.toUpperCase();	
			valid.reset();
			if(!valid.validate()){
				return;
			}
			if(!isQuery){
				alert('請先查詢');
				return;
			}
			var contentDSA33301 =  $('DSA33301').contentWindow;
			if(!contentDSA33301.DSA33301_validation()){
				return;
			}

			var COMMUNITY_NO = $F('COMMUNITY_NO');
			var UPDATE_TIME = $F('UPDATE_TIME');
			var reqMap = {
				COMMUNITY_NO : COMMUNITY_NO,
				UPDATE_TIME : UPDATE_TIME
			};
			
			<%--[20230703] 調整檢核 --%>
			ajaxRequest.post('doConfirmBeforeCheck1',reqMap,function(resp){ 
				
				<%--[20230803]  若基本資料分頁PUB_RATE_UPPER > (基本資料分頁PUB_RATE_LOWER +10)，跳出確認視窗，「公設比差值大於10%，確認是否仍要呈核」，若使用者確認後，才繼續作業 --%>
				var PUB_RATE_LOWER = contentDSA33301.$('PUB_RATE_LOWER').getValue();
				var PUB_RATE_UPPER = contentDSA33301.$('PUB_RATE_UPPER').getValue();
				var isConfirm = ( PUB_RATE_UPPER -PUB_RATE_LOWER ) > 10;
				if(isConfirm && !confirm('公設比差值大於10%，確認是否仍要呈核?')){
					return;
				}
				
				var isCheck = resp.isCheck || '';
				if('Y' == isCheck && !isConfirm && !confirm('公設比差值大於10%，確認是否仍要呈核?')){
					return;
				}
				reqMap['VALID'] = resp.VALID || '';
				ajaxRequest.post('doConfirmBeforeCheck2',reqMap,function(resp){ 
					var isCheck2 = resp.isCheck || '';
					if('Y' == isCheck2 && !confirm('社區未建置車位資料，請確認是否仍要呈核?')){
						return;
					}
					ajaxRequest.post('confirm',reqMap,function(resp){ 
						actions.clearSrc();
						actions.createTabs(COMMUNITY_NO, UPDATE_TIME);
					});
				});
			});
		},
		<%--[20221205]組長覆核--%>
		doCaptainConfirm : function(){	
			$('COMMUNITY_NO').value = $('COMMUNITY_NO').value.toUpperCase();	
			valid.reset();
			if(!valid.validate()){
				return;
			}
			if(!isQuery){
				alert('請先查詢');
				return;
			}
			var COMMUNITY_NO = $F('COMMUNITY_NO');
			var UPDATE_TIME = $F('UPDATE_TIME');
			
			ajaxRequest.post('captainConfirm', 
			{ 
				COMMUNITY_NO : COMMUNITY_NO,
				UPDATE_TIME : UPDATE_TIME
			},function(resp){ 
				actions.clearSrc();
				actions.createTabs(COMMUNITY_NO, UPDATE_TIME);
			});			
		},
		<%--[20221205]呈核--%>
		doConfirmReject : function(){	
			$('COMMUNITY_NO').value = $('COMMUNITY_NO').value.toUpperCase();	
			valid.reset();
			if(!valid.validate()){
				return;
			}
			if(!isQuery){
				alert('請先查詢');
				return;
			}
			var COMMUNITY_NO = $F('COMMUNITY_NO');
			var UPDATE_TIME = $F('UPDATE_TIME');
			
			ajaxRequest.post('confirmReject', 
			{ 
				COMMUNITY_NO : COMMUNITY_NO,
				UPDATE_TIME : UPDATE_TIME
			},function(resp){ 
				actions.clearSrc();
				actions.createTabs(resp.COMMUNITY_NO, resp.UPDATE_TIME);
				$('COMMUNITY_NO').value = resp.COMMUNITY_NO;	
				$('UPDATE_TIME').value = resp.UPDATE_TIME;	
			});			
		},
		<%--[20221205]刪除--%>
		doDelete : function(){	
			$('COMMUNITY_NO').value = $('COMMUNITY_NO').value.toUpperCase();	
			valid.reset();
			if(!valid.validate()){
				return;
			}
			if(!isQuery){
				alert('請先查詢');
				return;
			}
			var COMMUNITY_NO = $F('COMMUNITY_NO');
			var UPDATE_TIME = $F('UPDATE_TIME');
			
			ajaxRequest.post('delete', 
			{ 
				COMMUNITY_NO : COMMUNITY_NO,
				UPDATE_TIME : UPDATE_TIME
			},function(resp){ 
				actions.clearSrc();
				actions.createTabs(COMMUNITY_NO, UPDATE_TIME);
			});			
		}
		
		<%--新增--%>
		<%--doLinkToDSA3_3301 : function(){

			popupWin.windowOpen('<%=dispatcher%>/DSA3_3301/prompt',{
				'parameters': {'COMMUNITY_NO': ""},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		}--%>
	};
	var actions = {
		<%--產生分頁--%>
		createTabs : function(communityNo, updateTime){<%--[20221205] 新增參數updateTime--%>		
			tabs = new Tabs({
				id:'tabsMenu',
				tabs:allTabs,
				beforeSwitch: function(info){
					var f = $(info.to);
					<%--FRAME ID跟分頁ID相同，則設定FRAME SOURCE--%>
					for(var i = 0 ; i < allTabs.length ; i++){
						if('DSA33309' == allTabs[i].id){
							f.src= actions.genSrcP(allTabs[i].src, communityNo);
						    break;
						}else{
							if(info.to == allTabs[i].id){
							    f.src= actions.genSrc(allTabs[i].src, communityNo, updateTime);<%--[20221205] 新增參數updateTime--%>
							    break;
							}
						}
						/*if(info.to == allTabs[i].id){
						    f.src= actions.genSrc(allTabs[i].src, communityNo);
						    break;
						}*/
					}
				},
				beforeSwitchShowCover: true
			});			
		},
		<%--產生分頁SOURCE--%>		
		genSrc : function(scr, communityNo, updateTime){<%--[20221205] 新增參數updateTime--%>		
			return "${dispatcher}/" + scr + "/prompt?COMMUNITY_NO="+communityNo + '&UPDATE_TIME=' + updateTime + '&LINK_FROM=DSA33390';
		},
		<%--產生分頁SOURCE--%>		
		genSrcP : function(scr, communityNo){	
			return "${dispatcher}/" + scr + "/queryImgByCOMMUNITY_NO?iCOMMUNITY_NO="+communityNo + '&LINK_FROM=DSA33390';
		},
		<%--建議清單--%>
		suggestALL : function(){
			<%--社區編號搜尋，加入suggestion裡面--%>
			Suggest.add( 
				'COMMUNITY_NO', 			  
		        Suggest.URL,
				'${dispatcher}/DSA3_3390/suggestCommunityNo',
				{						
		            ignoreCase:true,
		            startLength:4,
		            option_key:"COMMUNITY_NO",
		            remark_key:"CASE_NAME",	
		            noCookies:false,
					"callBackFunc" : function(node,rec){}	
				}
			); 
			
			<%--社區名稱搜尋，加入suggestion裡面--%>
			Suggest.add( 
				'CASE_NAME', 			  
		        Suggest.URL,
				'${dispatcher}/DSA3_3390/suggestCaseName',
				{						
		            ignoreCase:true,
		            startLength:2,
		            option_key:"CASE_NAME",
		            remark_key:"COMMUNITY_NO",	
		            noCookies:true,
					"callBackFunc" : function(node,rec){ $('COMMUNITY_NO').setValue(rec ? rec['COMMUNITY_NO'] : ''); }	
				}
			);
		},
		<%--[20221205]清除舊的src，避免重查(抽離出來當共用方法)--%>	
		clearSrc : function(){	
			$('DSA33310').setAttribute('src', '');
			$('DSA33301').setAttribute('src', '');
			$('DSA33302').setAttribute('src', '');
			$('DSA33303').setAttribute('src', '');
			$('DSA33304').setAttribute('src', '');
			$('DSA33305').setAttribute('src', '');
			$('DSA33306').setAttribute('src', '');
			$('DSA33309').setAttribute('src', '');
		},
		clearTime : function(){
			$('UPDATE_TIME').setValue("");
		}
	};

	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement("DSA33390" , "鑑價作業" , "社區資料庫維護");
			$('btnQuery').observe('click' , buttons.doQuery);	
			//$('btnInsert').observe('click', buttons.doLinkToDSA3_3301 );//新增社區資料
			$('btnElectronicMap').observe('click', buttons.doElectronicMap ); //電子地圖
			<%--[20221205]新增'呈核'、'組長覆核'、'組長退回'、'刪除'按鈕--%>
			$('btnConfirm').observe('click' , buttons.doConfirm);
			$('btnCaptainConfirm').observe('click' , buttons.doCaptainConfirm);
			$('btnConfirmReject').observe('click' , buttons.doConfirmReject);
			$('btnDelete').observe('click' , buttons.doDelete);
			$('COMMUNITY_NO').observe('change' , actions.clearTime);
			
			initValidation();
			actions.suggestALL();
			<%--[20221205]新增按鈕權限--%>
			buttonAuth();
			$('COMMUNITY_NO').value = '${COMMUNITY_NO}';
			if($('COMMUNITY_NO').value != ''){
				buttons.doQuery();
			}			
		}
	};	
};

</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<center>
	<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table id="block_A" width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%" align="left">
					<span>社區編號</span>	
				</td>
				<td class="tbYellow2">
					<input name="COMMUNITY_NO" id="COMMUNITY_NO" type="text" class="textBox2" size="12" maxlength="10">
					<input name="UPDATE_TIME" id="UPDATE_TIME" type="hidden" value="${UPDATE_TIME}">
				</td>
				<td class="tbYellow" width="10%" align="left">
					<span>社區名稱</span>	
				</td>
				<td class="tbYellow2">
					<input name="CASE_NAME" id="CASE_NAME" type="text" class="textBox2" maxlength="40">
				</td>
				<td class="tbYellow2" width="50%">
					<input id="btnQuery" name="btnQuery" type="button" class="button" value="查詢">
					<!-- <input id="btnInsert" name="btnInsert" type="button" class="button" value="新增"> -->
					<input id="btnElectronicMap" name="btnElectronicMap" type="button" class="button" value="(2)電子地圖">
					<input id="btnConfirm" name="btnConfirm" type="button" class="button" value="(5)呈核">
					<input id="btnCaptainConfirm" name="btnCaptainConfirm" type="button" class="button" value="組長覆核">
					<input id="btnConfirmReject" name="btnConfirmReject" type="button" class="button" value="退回">
					<input id="btnDelete" name="btnDelete" type="button" class="button" value="刪除">			
				</td>
			</tr>	
		</table>	
	</form>
	
	<!----------------------------------- 查詢結果 begin---------------------------------->
	<div id='tabsMenu' style="width:100%"></div>		
	<div id="contents" class="tab">
		<iframe id="DSA33310" width="100%" border="0" style="display:none"></iframe>
		<iframe id="DSA33301" width="100%" border="0" style="display:none" scrolling="no"></iframe>
		<iframe id="DSA33302" width="100%" border="0" style="display:none" scrolling="yes"></iframe>
		<iframe id="DSA33303" width="100%" border="0" style="display:none" scrolling="yes"></iframe>
		<iframe id="DSA33304" width="100%" border="0" style="display:none" scrolling="yes"></iframe>
		<iframe id="DSA33305" width="100%" border="0" style="display:none" scrolling="yes"></iframe>
		<iframe id="DSA33306" width="100%" border="0" style="display:none" scrolling="yes"></iframe>
		<!-- <iframe id="DSA33307" width="100%" border="0" style="display:none" scrolling="yes"></iframe> -->
		<iframe id="DSA33309" width="100%" border="0" style="display:none" scrolling="yes"></iframe>														
	</div>
	<!----------------------------------- 查詢結果 end---------------------------------->
</center>

</body>
</html>