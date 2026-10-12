<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
程式：DSA21011.jsp
作者：i9300611
功能：UCDSA21011_主管裁決批示分頁畫面
完成：
更新：
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>
<script type="text/JavaScript">
<!--

Event.observe(window, 'load', initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

var DSA21011 = {};

function initApp(){

	displayMessage();

	PageUI.createPageWithAllBodySubElement( "DSA21011" , "核貸作業" ,"主管裁決批示 " );
	new UI().init();
}

function UI(){
	return {
		init:function() {

			//displayMessage();
			var qryMap = '${qryMap}'.evalJSON();
			if( msgs[0][0] == '無此受理編號資料!'){

				CSRUtil.linkBack("<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT="+ qryMap.CRED_DEPT+"&INST_LEVEL="+qryMap.INST_LEVEL+"&SUP_CRED_DEPT="+qryMap.SUP_CRED_DEPT);

			}else{

				var Tab_List = '${Tab_List}'.evalJSON();
				createTabs(Tab_List, qryMap);

				var iframeResize = {
					resize:function(){
						var height = document.body.clientHeight-100;
						$('iframeDiv').style.height = height;
						$$('iframe').each(function(elem){
							elem.style.height = height;
						});
					}
				}

				iframeResize.resize();
				UI_Manager.addUIConfig("iframeResize",iframeResize);


				//回待審件
				$('btn_DSA21010').observe('click',function(event){
						CSRUtil.linkBack("<%=dispatcher%>/DSA2_1010/prompt?CRED_DEPT="+ qryMap.CRED_DEPT+"&INST_LEVEL="+qryMap.INST_LEVEL+"&SUP_CRED_DEPT="+qryMap.SUP_CRED_DEPT);
					}
				);
	
				//$('tabsMenu').appendChild($('btn_DSA21010'));
			}
		}
	};
}

function createTabs(Tab_List, qryMap){

	var srcs = {};
	var tabArray = [];
	var APPLY_ID = qryMap.APPLY_ID;
	var REFER_ID = qryMap.REFER_ID;
	var INST_LEVEL = qryMap.INST_LEVEL;
	var INST_TYPE = qryMap.INST_TYPE;
	var CRED_DEPT = qryMap.CRED_DEPT;
	if(Tab_List){
		var length = Tab_List.length;
		
		//分頁1(主管裁決批示)
		if(length > 0){
			var FUNC_ID = Tab_List[0].FUNC_ID;
			var TITLE = Tab_List[0].TITLE;
			var INST_LEVEL = Tab_List[0].INST_LEVEL;
			var APPLY_ID = Tab_List[0].APPLY_ID;
			
			// 批示種類為變更年期
			if(INST_TYPE == 'M'){
				srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?REFER_ID="+Tab_List[0].REFER_ID+"&INST_LEVEL="+INST_LEVEL+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
				tabArray.push({'id': FUNC_ID, 'title': TITLE});
			}
			// 批示種類為簡易受理
			else if(INST_TYPE == 'E'){
				srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+APPLY_ID+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
				tabArray.push({'id': FUNC_ID, 'title': TITLE});
			}
			// 批示種類為一般件、快審件、退件、線上放審會、線上放審會之大額退件
			else if(INST_TYPE == "G" || INST_TYPE == "A" || INST_TYPE == "R" || INST_TYPE == "C" || INST_TYPE == "D" || INST_TYPE == "B"){
				if(INST_TYPE == "C" || INST_TYPE == "D"){
					srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+APPLY_ID+"&INST_LEVEL="+INST_LEVEL+"&INST_TYPE="+INST_TYPE+"&CRED_DEPT="+CRED_DEPT+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
				}else{
					srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+APPLY_ID+"&INST_LEVEL="+INST_LEVEL+"&INST_TYPE="+Tab_List[0].INST_TYPE+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
				}
				tabArray.push({'id': FUNC_ID, 'title': TITLE});
			}
		}

		//分頁2(鑑估表)
		if(length > 1){
			var FUNC_ID = Tab_List[1].FUNC_ID;
			srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+Tab_List[1].APPLY_ID+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
			//tabArray.push({'id': FUNC_ID, 'title': Tab_List[1].TITLE});
		}

		//分頁3(鑑價報告)
		if(length > 2){
			var FUNC_ID = Tab_List[2].FUNC_ID;
			//srcs[FUNC_ID]=linkToDPURL+"?checkPerm=A207&__UserID__="+UserID+"&SYS=DS&APPLY_ID="+Tab_List[2].APPLY_ID+"&titleNotDisplay=Y";
			srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+Tab_List[2].APPLY_ID+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
			tabArray.push({'id': FUNC_ID, 'title': Tab_List[2].TITLE});
		}

		//變更年期只有主管裁決批示、鑑估表、鑑價報告頁籤
		if(INST_TYPE != 'M'){
			//分頁4(貸款整合紀錄)
			if(length > 3){
				var FUNC_ID = Tab_List[3].FUNC_ID;
				srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?TYPE=A&VALUE="+Tab_List[3].APPLY_ID+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
				tabArray.push({'id': FUNC_ID, 'title': Tab_List[3].TITLE});
			}

			for(var i=4;i<length;i++){
				var FUNC_ID = Tab_List[i].FUNC_ID;
				if(FUNC_ID){
					srcs[FUNC_ID]="<%=dispatcher%>/"+FUNC_ID.substring(0,4)+"_"+FUNC_ID.substring(4,8)+"/prompt?APPLY_ID="+Tab_List[i].APPLY_ID+"&LINK_FROM=DSA21011&titleNotDisplay=Y";
					tabArray.push({'id': FUNC_ID, 'title': Tab_List[i].TITLE});
				}
			}
		}
	}
	if(tabArray.length > 0){
		//產生 tabs
		DSA21011.tabs = new Tabs({

			//欲產生 tab 的 div container
			id:'tabsMenu',

			//定義 tab 的 title，及點選時搭配 show/hide 的 elemnt id
			tabs:tabArray,
			beforeSwitch: function(info){
				//在第一次顯示該 iframe 時，才載入 src
				var f = $(info.to);
				var targetURL = srcs[info.to];
				var oriSRC = f.src;
			
				<%-- [20180328] 問題單20180327115719 頁籤轉換時不需重新查詢  --%>
				if(oriSRC && oriSRC.indexOf(targetURL) > 0) {
					return;
				}
				if(f.src.blank() || f.src != targetURL){
					f.src = targetURL;
				}
			}
		});
	}else{
		$('iframeDiv').hide();
	}
}

//-->
</script>
</head>
<body>
	<div id="iframeDiv">
		<input id="btn_DSA21010" name="btn_DSA21010" type="button" class="button" value="回待審件" style="float:right">
		<div id="bar1"></div>
		<!----------------------------------- 查詢結果 begin---------------------------------->
		<div id="tabsMenu" style="width:100%"></div>
		<div id="contents" class="tab">
			<iframe id="DSA21014" width="100%" border="0" style="display:none"></iframe><%-- 主管裁決批示 --%>
			<iframe id="DSA21015" width="100%" border="0" style="display:none"></iframe><%-- 線上放款審查會 --%>
			<iframe id="DSA22400" width="100%" border="0" style="display:none"></iframe><%-- 變更年期 --%>
			<iframe id="DSA21004" width="100%" border="0" style="display:none"></iframe><%-- 簡易受理 --%>
			<iframe id="DSA30500" width="100%" border="0" style="display:none"></iframe><%-- 鑑價報告 --%>
			<iframe id="DSA20200" width="100%" border="0" style="display:none"></iframe><%-- 貸款整合紀錄 --%>
			<iframe id="DSA20500" width="100%" border="0" style="display:none"></iframe><%-- 本息收支表 --%>
			<iframe id="DSA20410" width="100%" border="0" style="display:none"></iframe><%-- 聯徵紀錄 --%>
			<iframe id="DSA20901" width="100%" border="0" style="display:none"></iframe><%-- 進件評分表 --%>
			<iframe id="DSA20800" width="100%" border="0" style="display:none"></iframe><%-- 償債能力分析表 --%>
			<iframe id="DSA20601" width="100%" border="0" style="display:none"></iframe><%-- 簡易徵信報告 --%>
			<iframe id="DSA20600" width="100%" border="0" style="display:none"></iframe><%-- 徵信報告書 --%>
			<iframe id="DSA20700" width="100%" border="0" style="display:none"></iframe><%-- 客戶資料照會表 --%>
			<iframe id="DSA20701" width="100%" border="0" style="display:none"></iframe><%-- 買賣件查證 --%>
			<iframe id="DSA20500" width="100%" border="0" style="display:none"></iframe><%-- 本息收支表 --%>
			<iframe id="DSA20902" width="100%" border="0" style="display:none"></iframe><%-- 債信評等 --%>
		</div>
		<!----------------------------------- 查詢結果 end---------------------------------->
	</div>
</body>
</html>