<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>

<!--
程式：DSA32100.jsp
作者：簡睿甫
功能：初估申請作業_頁簽用主畫面
完成：
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/utility.js"></script>         <%-- 判斷BUTTON用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javaScript" src="<%=htmlBase%>/CM/js/ui/tabs.js"></script>         <%-- 頁簽使用 --%>

<script type="text/JavaScript">
var DSA32100 = new DSA32100();

Event.observe(window, 'load', DSA32100.initApp );
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);


function DSA32100(){
	// 畫面上的原件貸款帳號
	//var LOAN_ID;
	// 原件貸款帳號
	//var OLD_LOAN_ID;
	
	var isDSA32101Next = false;
	var isDSA32102Next = false;
	var isDSA32103Next = false;
	var isNoChanged = true;
	
	//-----------------------------------------------------
	//頁籤控制
	//-----------------------------------------------------
	function CreateTabs(){ 

		DSA32100.TABS = new Tabs({
		
			id:'tabsMenu',
			
			tabs:[
				{id:"DSA32101", "title":"基本資料輸入"},
				{id:"DSA32103", "title":"初估申請結果"}
			],
			selected:'DSA32101',
			beforeSwitch: function(info){
				//調整外部的高度大小，固定下來，讓上下的 scroll 不生效
				var h = document.body.clientHeight;
				
				//調整高度
				h = h  - 120;
				$$('#contents iframe').each(function(it){
					it.height = h;
				});

				// 下一步至下一頁時，資料重新帶入後刷新
				if(info.to == 'DSA32103'  && info.from == 'DSA32101') {
					var f = $(info.to);
					var infosMap = $('DSA32101').contentWindow.DSA32101.getInfo();
					f.src = '<%=dispatcher%>/DSA3_2103/prompt?PREAPPR_NO='+ (infosMap.get('PREAPPR_NO')?  infosMap.get('PREAPPR_NO'): '') + "&LOAN_ID="+ (infosMap.get('LOAN_ID')?  infosMap.get('LOAN_ID'): '')+ "&sourceChoose=" + (infosMap.get('sourceChoose')?  infosMap.get('sourceChoose'): '');
				}
			},
			beforeSwitchShowCover: true,
			afterSwitch: function(info){
				// 非經由按鈕"下一步" 及 來自DSA32101的
				if(!DSA32100.isDSA32101Next && info.from == 'DSA32101') { 
					var infos = $('DSA32101').contentWindow.DSA32101.isChanged(info);
					
					new Ajax.Request(
					"<%=dispatcher%>/DSA3_2101/isChanged", 
						{ parameters : {A285Map: Object.toJSON(infos.A285Map), A285List: Object.toJSON(infos.A285List)} ,
						  onSuccess : function (response) {
							var resp = response.responseJSON;
							if(CSRUtil.isSuccess(resp)){      
								hasChange = resp.isChanged;
								if(hasChange){
									alert("畫面資料有異動,請按下一步或結案案件變更");
									DSA32100.isNoChanged = false;
									DSA32100.TABS.select('DSA32101');
								}else{
									DSA32100.isNoChanged = true;
								}
							} else {
								DSA32100.TABS.select(info.from);
							}
						 }
					});
					
					
					// 來自 DSA32103 (非來自DSA32101的)的
				} else if(info.from == 'DSA32103') { // if(!DSA32100.isDSA32103Next && info.from == 'DSA32103')
					$('DSA32103').contentWindow.DSA32103().isChanged(info);	
					
					// 經由按鈕"下一步" 及 來自DSA32101的
				} else {
					DSA32100.isDSA32101Next = false;
					/*if(DSA32100.isDSA32101Next && info.from == 'DSA32101') {
						DSA32100.isDSA32101Next = false;
					} else if(DSA32100.isDSA32102Next && info.from == 'DSA32102') {
						DSA32100.isDSA32102Next = false;
					} else if(!DSA32100.isDSA32103Next && info.from == 'DSA32103') { 
						DSA32100.isDSA32102Next = false;
					}*/
				}
				
				if(info.to == 'DSA32103' && DSA32100.isNoChanged && info.from != 'DSA32101'){
					var cover = CSRUtil.createCoverPage('_frontCover');
					cover.show();
					var f = $('DSA32103');
					var infosMap = $('DSA32101').contentWindow.DSA32101.getInfo();
					f.src = '<%=dispatcher%>/DSA3_2103/prompt?PREAPPR_NO='+ (infosMap.get('PREAPPR_NO')?  infosMap.get('PREAPPR_NO'): '') + "&LOAN_ID="+ (infosMap.get('LOAN_ID')?  infosMap.get('LOAN_ID'): '')+ "&sourceChoose=" + (infosMap.get('sourceChoose')?  infosMap.get('sourceChoose'): '');
					cover.hide();
				}
				
				/*if(info.to == 'DSA32102' && DSA32100.isNoChanged && info.from != 'DSA32101'){
					var cover = CSRUtil.createCoverPage('_frontCover');
					cover.show();
					var f = $('DSA32102');
					var infosMap = $('DSA32101').contentWindow.DSA32101.getInfo();
					f.src = '<%=dispatcher%>/DSA3_2102/prompt?PREAPPR_NO='+ (infosMap.get('PREAPPR_NO')?  infosMap.get('PREAPPR_NO'): '') + "&LOAN_ID="+ (infosMap.get('LOAN_ID')?  infosMap.get('LOAN_ID'): '')+"&OLD_LOAN_ID="+ (infosMap.get('OLD_LOAN_ID')?  infosMap.get('OLD_LOAN_ID'): '');
					cover.hide();
				}*/
			}
		});
	}
	
	return {
		initApp : function() {
			CreateTabs();
			PageUI.createPageWithAllBodySubElement( "DSA32100" , "鑑價作業", "初估申請作業");
			PageUI.resize();
			alert("本線上初估系統為簡略性作業畫面，僅供申貸與否參考，實際仍需查詢借款人債信及擔保品實地勘查");
			displayMessage();					
		},// end initApp()--
		isDSA32101Next : isDSA32101Next,
		//isDSA32102Next : isDSA32102Next,
		isDSA32103Next : isDSA32103Next,
		isNoChanged : isNoChanged,
		afterDSA32103Delete: function() {
			var LP_JSON = {};
			LP_JSON.action = "<%=dispatcher%>/DSA3_2100/prompt";
			
			CSRUtil.linkTo(LP_JSON, 'form');
		}
		
	}// end return--
}// end DSA32100

</script>
</head>

<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<div id='tabsMenu'></div>	
	<form id="form"></form>
	<div id="contents" class="tab">
		<iframe id="DSA32101" width="100%" scrolling="auto" border="0" style="display:none" scrolling="no" src="<%=dispatcher%>/DSA3_2101/prompt?PREAPPR_NO=${PREAPPR_NO}" ></iframe>
		<iframe id="DSA32103" width="100%" scrolling="auto" border="0" style="display:none" scrolling="no" src="<%=dispatcher%>/DSA3_2103/prompt?PREAPPR_NO=${PREAPPR_NO}" ></iframe>
	</div>
</body>
</html>