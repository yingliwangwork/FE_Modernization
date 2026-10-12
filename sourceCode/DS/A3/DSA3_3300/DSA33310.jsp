<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA33310.jsp
作者：李明翰
功能：社區資料庫
完成：

[20230118] 修改件 陳勁谷 C區新增「充電樁設備」欄位
[20230710][20230707091059] F區車位資料清單移除地下樓層
[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
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
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>

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
Event.observe(window, 'load', new DSA33310().initApp);
function DSA33310(){

	var gridD;
	var gridE;
	var gridF;
	var gridH;
	var gridI;
	var gridK1;
	var gridK2;

	<%-- TablE UI物件 --%>
	var FUNC_ID = 'DSA33310';
	
	<%-- 按鈕權限 --%>
	function buttonAuth(){
		var authButtons = {
				B0004:"BTN_UPDATE" //修改
		};
		<dz:grantButtons FUNC_ID="DSA33310" ignored="false"/>
	}
	
	var actions = {			
		<%--初始畫面--%>
		initLayOut : function(){
			var isBankUser = <c:out value="${IS_BANK_USER}" escapeXml="false" default='[]' />;

			var A350Map = <c:out value="${A350Map}" escapeXml="false" default='{}' />;

			actions.setDivVisible(isBankUser);	
			actions.genGeneralZone(A350Map);
			if(!isBankUser){
				actions.genAPPRZone(A350Map);	
				$('DSA33308').setAttribute('src','${dispatcher}/DSA3_3308/prompt?COMMUNITY_NO=${COMMUNITY_NO}');			
			}else{
				actions.genBANKZone(A350Map);
				//$('DSA33308').setAttribute('src','${dispatcher}/DSA3_2400/prompt?CathayNo=${COMMUNITY_NO}&ActionType=07');
				$('form2').setAttribute('action','${dispatcher}/DSA3_2400/prompt?CathayNo=${COMMUNITY_NO}&ActionType=07');
				$('form2').submit();
			}		
		},	
		<%--如果是銀行員工，則不顯示以下區塊--%>		
		setDivVisible : function(isBankUser){
			if(!isBankUser){
				$('block_C').hide();
			}else{
				$('block_B').hide();
				$('block_D').hide();
				$('block_F').hide();
				$('block_I').hide();
				$('block_K').hide();
			}
		},
		<%--影像顯示點選後會展開--%>		
		doShowdiv_GridJ : function(){
			<%--取得Iframe DSA33308下的DataSize欄位判斷是否有值，contentDocument支援chrome以上，document支援IE11--%>
			var iframe = window.frames['DSA33308'];
			var iframeObj = iframe.contentDocument || iframe.document;
			/*if(iframeObj.getElementById("DataSize").value == '0'){
				alert('無影像資料');
				return;
			}else{
				if($('div_GridJ').style.display != 'none'){
					$('div_GridJ').hide();
				}else{
					$('div_GridJ').show();
				}			
			}*/
			if($('div_GridJ').style.display != 'none'){
				$('div_GridJ').hide();
			}else{
				$('div_GridJ').show();
			}	
		},
		<%--使照資料點選後會展開--%>		
		doShowdiv_GridI : function(){
			if($('div_GridI').style.display != 'none'){
				$('div_GridI').hide();
			}else{
				$('div_GridI').show();
			}			
		},
		<%--一般資料區塊--%>		
		genGeneralZone : function(A350Map) {	
			<%--load A--%>
			$w('CASE_NAME COMMUNITY_NO CITY DIST ADDR_NO').each( 
				function(id) {
					$(id).update((A350Map[id] || A350Map[id] == 0) ? A350Map[id] : '');
				}
			);		
			
			<%--資料更新日--%>		
			$('UPDATE_DATE').update(Date.toROC(A350Map['UPDATE_DATE']) || '');
			
			<%--load G MRT_DESC--%>
			actions.genMRTDesc(A350Map, <c:out value="${A353ListMap}" escapeXml="false" default='[]' />);
			
			<%--load E,H--%>
			gridE.load(<c:out value="${A354ParkListMap}" escapeXml="false" default='[]' />);
			gridH.load(<c:out value="${A352ListMap}" escapeXml="false" default='[]' />);	
			
		},
		<%--非銀行員工區塊--%>		
		genAPPRZone : function(A350Map) {	
			<%--load B--%>
			$('USE_FOR_B').update((A350Map['USE_FOR'] || A350Map['USE_FOR'] == 0) ? A350Map['USE_FOR'] : '');
			$('HOUSE_NO_B').update((A350Map['HOUSE_NO'] || A350Map['HOUSE_NO'] == 0) ? A350Map['HOUSE_NO'] : '');
			$('HOUSE_AGE_B').update((A350Map['HOUSE_AGE'] || A350Map['HOUSE_AGE'] == 0) ? A350Map['HOUSE_AGE'] : '');
			$('FLOOR_B').update((A350Map['FLOOR'] || A350Map['FLOOR'] == 0) ? A350Map['FLOOR'] : '');
			$('BASEMENT_FLOOR_B').update((A350Map['BASEMENT_FLOOR'] || A350Map['BASEMENT_FLOOR'] == 0) ? A350Map['BASEMENT_FLOOR'] : '');
			$('RESTRICT_AREA_B').update((A350Map['RESTRICT_AREA'] || A350Map['RESTRICT_AREA'] == 0) ? A350Map['RESTRICT_AREA'] : '');
			$('ROAD_NAME_B').update((A350Map['ROAD_NAME'] || A350Map['ROAD_NAME'] == 0) ? A350Map['ROAD_NAME'] : '');
			$('ROAD_WIDTH_B').update((A350Map['ROAD_WIDTH'] || A350Map['ROAD_WIDTH'] == 0) ? A350Map['ROAD_WIDTH'] : '');
			$('LIQUE_AREA_B').update((A350Map['LIQUE_AREA'] || A350Map['LIQUE_AREA'] == 0) ? A350Map['LIQUE_AREA'] : '');
			$('TRFC_FUNC_B').update((A350Map['TRFC_FUNC'] || A350Map['TRFC_FUNC'] == 0) ? A350Map['TRFC_FUNC'] : '');
			$('LIFE_FUNC_B').update((A350Map['LIFE_FUNC'] || A350Map['LIFE_FUNC'] == 0) ? A350Map['LIFE_FUNC'] : '');
			$('MANAGE_STATUS_B').update((A350Map['MANAGE_STATUS'] || A350Map['MANAGE_STATUS'] == 0) ? A350Map['MANAGE_STATUS'] : '');
			$w('SALE_RATE REST_RATE LICENSE_NO MATERIAL VALUATION_1 VALUATION_2 VALUATION_4').each( 
				function(id) { 
					$(id).update((A350Map[id] || A350Map[id] == 0) ? A350Map[id] : '');
				}
			);
			
			<%--[20220331]新增國宅社區欄位--%>
			$('IS_PUBLIC').update((A350Map['IS_PUBLIC'] || A350Map['IS_PUBLIC'] == 0) ? A350Map['IS_PUBLIC'] : '');
			
			<%--[20220718]新增生活圈欄位--%>
			$('SUBMKT_NAME').update((A350Map['SUBMKT_NAME'] || A350Map['SUBMKT_NAME'] === 0) ? A350Map['SUBMKT_NAME'] : '');
			
			<%--相似社區區塊--%>		//[20221216]不顯示相似社區
			//commonTools.createLink(A350Map.COMMUNITY_SLI1_NAME, A350Map.COMMUNITY_SLI1, $('COMMUNITY_SLI1'));
			//commonTools.createLink(A350Map.COMMUNITY_SLI2_NAME, A350Map.COMMUNITY_SLI2, $('COMMUNITY_SLI2'));
			//commonTools.createLink(A350Map.COMMUNITY_SLI3_NAME, A350Map.COMMUNITY_SLI3, $('COMMUNITY_SLI3'));
			//commonTools.createLink(A350Map.COMMUNITY_SLI4_NAME, A350Map.COMMUNITY_SLI4, $('COMMUNITY_SLI4'));

			<%--[20230118] 修改件 陳勁谷 C區新增「充電樁設備」欄位 --%>
			$('CHARGING').update(A350Map['CHARGING'] || '');
			
			<%--建築完成日--%>		
			$('FINISH_DATE').update(Date.toROC(A350Map['FINISH_DATE']) || '');
			<%--外觀照日期--%>		
			$('UPDATE_PIC_DATE').update(Date.toROC(A350Map['UPDATE_PIC_DATE']) || '');

			
			<%--公設比區間--%>		
			var PUB_RATE_LOWER = '';
			if(A350Map.PUB_RATE_LOWER){
				PUB_RATE_LOWER = PUB_RATE_LOWER + A350Map.PUB_RATE_LOWER +"%"
			}
			var PUB_RATE_UPPER = '';
			if(A350Map.PUB_RATE_UPPER){
				PUB_RATE_UPPER = PUB_RATE_UPPER + A350Map.PUB_RATE_UPPER +"%"
			}
			if(PUB_RATE_LOWER || PUB_RATE_UPPER){
				$('PUB_RATE').update(PUB_RATE_LOWER + '~' + PUB_RATE_UPPER);				
			}
			
			
			
			<%--load D,F,I,K1,K2--%>
			gridD.load(<c:out value="${A351ListMap}" escapeXml="false" default='[]' />);
			gridF.load(<c:out value="${A354ListMap}" escapeXml="false" default='[]' />);
			gridI.load(<c:out value="${A355ListMap}" escapeXml="false" default='[]' />);	
			gridK1.load(<c:out value="${A260ListMap}" escapeXml="false" default='[]' />);
			gridK2.load(<c:out value="${A263ListMap}" escapeXml="false" default='[]' />);
			gridL.load(<c:out value="${A357ListMap}" escapeXml="false" default='[]' />);
			if(gridL.hasRecords()){
				gridL.sort('FLOOR', true, 'number');//2018-03-12林孟平:TABLEUI有BUG，沒資料會當掉
			}
			
		},
		<%--銀行員工區塊--%>		
		genBANKZone : function(A350Map) {	
			<%--load C--%>
			$('USE_FOR_C').update((A350Map['USE_FOR'] || A350Map['USE_FOR'] == 0) ? A350Map['USE_FOR'] : '');
			$('HOUSE_NO_C').update((A350Map['HOUSE_NO'] || A350Map['HOUSE_NO'] == 0) ? A350Map['HOUSE_NO'] : '');
			$('HOUSE_AGE_C').update((A350Map['HOUSE_AGE'] || A350Map['HOUSE_AGE'] == 0) ? A350Map['HOUSE_AGE'] : '');
			$('FLOOR_C').update((A350Map['FLOOR'] || A350Map['FLOOR'] == 0) ? A350Map['FLOOR'] : '');
			$('BASEMENT_FLOOR_C').update((A350Map['BASEMENT_FLOOR'] || A350Map['BASEMENT_FLOOR'] == 0) ? A350Map['BASEMENT_FLOOR'] : '');
			$('RESTRICT_AREA_C').update((A350Map['RESTRICT_AREA'] || A350Map['RESTRICT_AREA'] == 0) ? A350Map['RESTRICT_AREA'] : '');
			$('ROAD_NAME_C').update((A350Map['ROAD_NAME'] || A350Map['ROAD_NAME'] == 0) ? A350Map['ROAD_NAME'] : '');
			$('ROAD_WIDTH_C').update((A350Map['ROAD_WIDTH'] || A350Map['ROAD_WIDTH'] == 0) ? A350Map['ROAD_WIDTH'] : '');
			$('LIQUE_AREA_C').update((A350Map['LIQUE_AREA'] || A350Map['LIQUE_AREA'] == 0) ? A350Map['LIQUE_AREA'] : '');
			$('SALE_RATE_C').update((A350Map['SALE_RATE'] || A350Map['SALE_RATE'] == 0) ? A350Map['SALE_RATE'] : '');
			$('REST_RATE_C').update((A350Map['REST_RATE'] || A350Map['REST_RATE'] == 0) ? A350Map['REST_RATE'] : '');
			$('TRFC_FUNC_C').update((A350Map['TRFC_FUNC'] || A350Map['TRFC_FUNC'] == 0) ? A350Map['TRFC_FUNC'] : '');
			$('LIFE_FUNC_C').update((A350Map['LIFE_FUNC'] || A350Map['LIFE_FUNC'] == 0) ? A350Map['LIFE_FUNC'] : '');
			$('MANAGE_STATUS_C').update((A350Map['MANAGE_STATUS'] || A350Map['MANAGE_STATUS'] == 0) ? A350Map['MANAGE_STATUS'] : '');
		},
		<%--環境資料--%>		
		genMRTDesc : function(A350Map, A353ListMap){
			
			<%--load MRT_DESC--%>				
			var MRT_DESC = '';
			if(A350Map.BUILD_LINE){
				MRT_DESC = MRT_DESC + '屬' + A350Map.BUILD_LINE + A350Map.BUILD_STATION + '之捷運共構產品<br>';				
			}
			if(A350Map.ROUND_LINE){
				MRT_DESC = MRT_DESC + '屬' + A350Map.ROUND_LINE + A350Map.ROUND_STATION  + A350Map.ROUND_EXIT 
							+ '號出口，為圓心' + A350Map.ROUND_DISTANCE + '之建物<br>';				
			}
			<%--拿掉最後的<br>--%>
			if(MRT_DESC.length > 0){
				MRT_DESC = MRT_DESC.substring(0, MRT_DESC.length -4);
			}			
			$('MRT_DESC').update(MRT_DESC);
			
			<%--load DISLIKE_LIST AND SPC_LIST--%>				
			var DISLIKE_LIST = '';
			var SPC_LIST = '';
			
			for(var i = 0 ; i < A353ListMap.length ; i++ ){
				var obj = A353ListMap[i];	
				if(obj.SPC_KIND == 'A' || obj.SPC_KIND == 'C'){
					if (obj.SPC_EFFECT) {
						SPC_LIST = SPC_LIST + '近'  + obj.SPC_NAME + '約' +  obj.SPC_DISTANCE + '公尺，影響' + obj.SPC_EFFECT + '<br>';
					} else {
						SPC_LIST = SPC_LIST + '近'  + obj.SPC_NAME + '約' +  obj.SPC_DISTANCE + '公尺<br>';
					}
				}else if(obj.SPC_KIND == 'B'){
					if (obj.SPC_EFFECT) {
						DISLIKE_LIST = DISLIKE_LIST + '近' + obj.SPC_NAME + '約' +  obj.SPC_DISTANCE + '公尺，影響' + obj.SPC_EFFECT + '<br>';
					} else {
						DISLIKE_LIST = DISLIKE_LIST + '近' + obj.SPC_NAME + '約' +  obj.SPC_DISTANCE + '公尺<br>';
					}
				}
			}
			
			<%--拿掉最後的<br>--%>
			if(DISLIKE_LIST.length > 0){
				DISLIKE_LIST = DISLIKE_LIST.substring(0, DISLIKE_LIST.length -4);
			}
			$('DISLIKE_LIST').update(DISLIKE_LIST);
			
			<%--拿掉最後的<br>--%>
			if(SPC_LIST.length > 0){
				SPC_LIST = SPC_LIST.substring(0, SPC_LIST.length -4);
			}
			$('SPC_LIST').update(SPC_LIST);
			
			$('DISLIKE_DESC_VIEW').value=A350Map.DISLIKE_DESC ? A350Map.DISLIKE_DESC : '';
			$('SPC_DESC_VIEW').value=A350Map.SPC_DESC ? A350Map.SPC_DESC : '';
			//模擬textarea keyup動作
			$w('DISLIKE_DESC_VIEW SPC_DESC_VIEW').each( 
				function(id){
					$(id).simulate('keyup');
				}
			);
		},
		<%--點選link的行為--%>		
		doLinkToDSA3_3310 : function(communityNO){
			return function(){				
				$('H_COMMUNITY_NO').setValue(communityNO);
		    	document.form1.action = "${dispatcher}/DSA3_3310/prompt";
		    	document.form1.target = "_blank";
		    	submitOnce($('form1'));
			}
		},
		<%--修改(連結至DSA33390)--%>		
		doLinkToDSA3_3390 : function(){
			var LP_JSON = {				  		    
       			'COMMUNITY_NO' : '${COMMUNITY_NO}'							
       		};
            LP_JSON.action = "<%=dispatcher%>/DSA3_3390/prompt";
            CSRUtil.linkTo(LP_JSON , "form1");
		}
	};	
	
	var commonTools = {
		<%--產生span的連結--%>
		createLink : function(linkValue, submitData, spanField){
			if(linkValue){
				var link = new Element( 'a' , { href : '#' } ).update(linkValue);									
				link.observe('click', actions.doLinkToDSA3_3310(submitData));	
				spanField.insert(link);
			}else{
				//查無社區資料有可能已刪除，明細畫面不顯示
				spanField.update("");
			}
		}	
	};
	return {
	
		initApp : function() {
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' />				
			PageUI.createPage("DSA33310", "鑑價作業", "社區資料明細", true);
			PageUI.loadin(["form1","form2"] , 0);
			
			gridD = new TableUI({
			 	table: $("gridD"),
				pageSize:0, 
				column:[	
					{header:"地址", key:'ADDR_NO', attrs : { Width : '40%'}, styles:{'font-family':'EUDC'} },<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>					
					{header:"列管類型", key:'RESTRICT_AREA', attrs : { Width : '30%'} },					
					{header:"列管原因", key:'RESTRICT_NOTE', attrs : { Width : '30%'} }				
				]
			});			
			gridE = new TableUI({
			 	table: $("gridE"),
				pageSize:0, 
				column:[	
					{header:"車位型態", key:'PARK', attrs : { Width : '40%'}},						
					{header:"車位價下限(萬/個)", key:'MIN_PARK_PRICE', attrs : { Width : '30%'}, sortRule:'number'},					
					{header:"車位價上限(萬/個)", key:'MAX_PARK_PRICE', attrs : { Width : '30%'}, sortRule:'number'}					
				]
			});		
			gridF = new TableUI({
			 	table: $("gridF"),
				pageSize:0, 
				column:[	
					<%--[20230710][20230707091059] F區車位資料清單移除地下樓層--%>
					{header:"車位型態", key:'PARK', attrs : { Width : '25%'}},					
					{header:"車位坪數", key:'PARK_SPACE', attrs : { Width : '25%'}, sortRule:'number'},	
					{header:"車位價(萬)", key:'PARK_PRICE', attrs : { Width : '25%'}, sortRule:'number'}					
				]
			});			
			gridH = new TableUI({
			 	table: $("gridH"),
				pageSize:0, 
				column:[	
					{header:"使用分區", key:'USE_AREA1', attrs : { Width : '15%'}},						
					{header:"使用註記", key:'USE_AREA2', attrs : { Width : '35%'}},					
					{header:"段名", key:'LOCATION2', attrs : { Width : '15%'}},	
					{header:"小段名", key:'LOCATION3', attrs : { Width : '15%'}},					
					{header:"地號1", key:'LAND_NO1', attrs : { Width : '10%'}},					
					{header:"地號2", key:'LAND_NO2', attrs : { Width : '10%'}}			
				]
			});	
			gridI = new TableUI({
			 	table: $("gridI"),
				pageSize:0, 
				column:[	
					{header:"樓層別", key:'FLOOR', attrs : { Width : '33%'}},						
					{header:"樓層用途", key:'FLOOR_USE', attrs : { Width : '33%'}},					
					{header:"樓層高度(m)", key:'FLOOR_HIGH', attrs : { Width : '34%'}}	
				]
			});	
			gridK1 = new TableUI({
			 	table: $("gridK1"),
				pageSize:0, 
				column:[	
					{header:"地址", key:'ADDR_NO', attrs : { Width : '40%'}, styles:{'font-family':'EUDC'}},	<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>			
					{header:"鑑估日期", key:'APPR_DATE', attrs : { Width : '10%'}, sortRule:'date'},
					{header:"樓層別", key:'FLOOR', attrs : { Width : '10%'}},					
					{header:"房屋坪數", key:'BUILD_AREA_ADJ', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"建坪單價", key:'PER_PRICE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"車位坪數", key:'PARK_SPACE', attrs : { Width : '10%'}, sortRule:'number'},	
					{header:"車位總價(萬)", key:'PARK_AMT', attrs : { Width : '10%'}, sortRule:'number'}	
				]
			});	
			gridK2 = new TableUI({
			 	table: $("gridK2"),
				pageSize:0, 
				column:[	
					{header:"地址", key:'ADDR_NO', attrs : { Width : '40%'}, styles:{'font-family':'EUDC'}},	<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>				
					{header:"成交日期", key:'TRADE_DATE', attrs : { Width : '10%'}, sortRule:'date'},
					{header:"樓層別", key:'FLOOR', attrs : { Width : '10%'}},					
					{header:"建坪(不含車位面積)(坪)", key:'BUILD_MEASURE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"建坪單價(不含車位價格)(萬/坪)", key:'PER_PRICE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"車位總面積(坪)", key:'PARK_MEASURE', attrs : { Width : '10%'}, sortRule:'number'},		
					{header:"車位總價(萬)", key:'PARK_T_PRICE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"車位型態", key:'PARK_TYPE', attrs : { Width : '10%'}}// 2021鑑價作業優化 新增車位型態欄位
				]
			});
			gridL = new TableUI({
				table: $("gridL"),pageSize: 20,              
				column:[
					{header: "樓層", key:'FLOOR', sortRule:'number', groupKey:["FLOOR"] },
					{header: "建坪", key:'FOOTAGE', sortRule:'number', groupKey:["FOOTAGE"] },
					{header: "總價", key:'PRICE' },
					{header: "待售資料來源", key:'SOURCE_NM' },
					/*
					{header: "待售資料來源", key:'SOURCE',
						render:function(rec,val){
							var span = new Element('span');
							if('S' == val){
								span.update('信義');
							}else if('Y' == val){
								span.update('永慶');
							}else if('5' == val){
								span.update('591');
							}
							return span;
						}
					},
					*/
					{header: "搜尋結果", key:'SEARCH_RESULT', sortable:false,
						render:function(rec,val){
							var alink = new Element('a',{href: '#'}).update(val);
							alink.observe('click', function(){
								window.open(rec.LINK, "DSA3_3310", "top=0, left=0, toolbar=yes, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=1280, height=768");
							});
							return alink;
						}
					}
				]
			});
			
			buttonAuth();
			//社區資料庫維護畫面(DSA33390)不顯示修改按鈕
			if ('${LINK_FROM}'){
				$('BTN_UPDATE').hide();
			}
			$("BTN_UPDATE").observe("click", actions.doLinkToDSA3_3390 );//修改
			$("A_div_GridI").observe("click", actions.doShowdiv_GridI );
			$("A_div_GridJ").observe("click", actions.doShowdiv_GridJ );
			actions.initLayOut();
			parseEUDC();
			displayMessage();	
		}	
	};	
}
</script>
</head>
<body>
	<form id="form1" name="form1"> 			
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_A">	
			<tr class="tbYellow">
				<td>社區名稱</td>
				<td align="left" class="tbYellow2" >
					<span id="CASE_NAME"></span>
				</td>
				<td>社區編號</td>
				<td align="left" class="tbYellow2" colspan="3">
					<span id="COMMUNITY_NO"></span>
					<input id="H_COMMUNITY_NO" name="COMMUNITY_NO" type="hidden"/>
					<input id="BTN_UPDATE" name="BTN_UPDATE" type="button" class="button" value="修改">
				</td>								
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow" width="10%">縣市別</td>
				<td align="left" class="tbYellow2" width="23%">
					<span id="CITY"></span>
				</td>
				<td class="tbYellow" width="10%">鄉鎮市區</td>
				<td align="left" class="tbYellow2" width="23%">
					<span id="DIST"></span>
				</td>
				<td class="tbYellow" width="10%">資料更新日</td>
				<td align="left" align="left" class="tbYellow2" width="24%">
					<span id="UPDATE_DATE"></span>
				</td>							
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">地址(代表號)</td>
				<td align="left" class="tbYellow2" colspan="5">
					<span id="ADDR_NO" style="font-family:'EUDC'"></span><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>						
			</tr>			
		</table>
	</form>
	<form id="form2" name="form2" action="" target="DSA33308" method="post"> 
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_B">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>一、基本資料</strong>
				</td>
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow" width="10%">建築型態</td>
				<td align="left" class="tbYellow2" width="23%">
					<span id="USE_FOR_B"></span>
				</td>
				<td class="tbYellow" width="10%">使照戶數</td>
				<td align="left" class="tbYellow2" width="23%">
					<span id="HOUSE_NO_B"></span>
				</td>	
				<td class="tbYellow" width="10%">屋齡(年)</td>
				<td align="left" class="tbYellow2" width="24%">
					<span id="HOUSE_AGE_B"></span>
				</td>											
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">總樓層</td>
				<td align="left" class="tbYellow2">
					<span id="FLOOR_B"></span>
				</td>
				<td class="tbYellow">地下層</td>
				<td align="left" class="tbYellow2">
					<span id="BASEMENT_FLOOR_B"></span>
				</td>
				<td class="tbYellow">列管區</td>
				<td align="left" class="tbYellow2">
					<span id="RESTRICT_AREA_B"></span>
				</td>							
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">正面路名</td>
				<td align="left" class="tbYellow2">
					<span id="ROAD_NAME_B"></span>
				</td>
				<td class="tbYellow">正面路寬(m)</td>
				<td align="left" class="tbYellow2">
					<span id="ROAD_WIDTH_B"></span>
				</td>
				<td class="tbYellow">土壤液化區</td>
				<td align="left" class="tbYellow2">
					<span id="LIQUE_AREA_B"></span>
				</td>							
			</tr>	
			<tr class="tbYellow">
				<td width="10%" class="tbYellow">銷售率</td>
				<td align="left" width="23%" class="tbYellow2">
					<span id="SALE_RATE"></span>
				</td>
				<td width="10%" class="tbYellow">進駐率</td>
				<td align="left" width="23%" class="tbYellow2">
					<span id="REST_RATE"></span>
				</td>	
				<td width="10%" class="tbYellow">交通機能</td>
				<td align="left" width="24%" class="tbYellow2">
					<span id="TRFC_FUNC_B"></span>
				</td>											
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">使照號碼</td>
				<td align="left" class="tbYellow2">
					<span id="LICENSE_NO"></span>
				</td>
				<td class="tbYellow">建築完成日</td>
				<td align="left" class="tbYellow2">
					<span id="FINISH_DATE"></span>
				</td>
				<td class="tbYellow">生活機能</td>
				<td align="left" class="tbYellow2">
					<span id="LIFE_FUNC_B"></span>
				</td>							
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">主要構造</td>
				<td align="left" class="tbYellow2">
					<span id="MATERIAL"></span>
				</td>
				<td class="tbYellow">外觀照日期</td>
				<td align="left" class="tbYellow2">
					<span id="UPDATE_PIC_DATE"></span>
				</td>
				<td class="tbYellow">管理情形</td>
				<td align="left" class="tbYellow2">
					<span id="MANAGE_STATUS_B"></span>
				</td>							
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">公設比區間</td>
				<td align="left" class="tbYellow2">
					<span id="PUB_RATE"></span>
				</td>
				<td class="tbYellow">國宅社區</td>
				<td align="left" class="tbYellow2">
					<span id="IS_PUBLIC"></span>
				</td>
				<td class="tbYellow">生活圈</td>
				<td align="left" class="tbYellow2">
					<span id="SUBMKT_NAME"></span>
				</td>
			</tr>	
			<%--[20230118] 修改件 陳勁谷 C區新增「充電樁設備」欄位 --%>
			<tr>
				<td class="tbYellow">充電樁設備</td>
				<td align="left" class="tbYellow2" colspan="5">
					<span id="CHARGING"></span>
				</td>
			</tr>
		</table>	
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_C">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>一、基本資料</strong>
				</td>
			</tr>	
			<tr class="tbYellow">
				<td class="tbYellow" width="10%">建築型態</td>
				<td align="left" class="tbYellow2" width="23%">
					<span id="USE_FOR_C"></span>
				</td>
				<td class="tbYellow" width="10%">使照戶數</td>
				<td align="left" class="tbYellow2" width="23%">
					<span id="HOUSE_NO_C"></span>
				</td>	
				<td class="tbYellow" width="10%">屋齡(年)</td>
				<td align="left" class="tbYellow2" width="24%">
					<span id="HOUSE_AGE_C"></span>
				</td>											
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">總樓層</td>
				<td align="left" class="tbYellow2">
					<span id="FLOOR_C"></span>
				</td>
				<td class="tbYellow">地下層</td>
				<td align="left" class="tbYellow2">
					<span id="BASEMENT_FLOOR_C"></span>
				</td>
				<td class="tbYellow">列管區</td>
				<td align="left" class="tbYellow2">
					<span id="RESTRICT_AREA_C"></span>
				</td>							
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow">正面路名</td>
				<td align="left" class="tbYellow2">
					<span id="ROAD_NAME_C"></span>
				</td>
				<td class="tbYellow">正面路寬(m)</td>
				<td align="left" class="tbYellow2">
					<span id="ROAD_WIDTH_C"></span>
				</td>
				<td class="tbYellow">土壤液化區</td>
				<td align="left" class="tbYellow2">
					<span id="LIQUE_AREA_C"></span>
				</td>							
			</tr>	
			<tr class="tbYellow">
				<td width="10%" class="tbYellow">銷售率</td>
				<td align="left"  width="23%" class="tbYellow2">
					<span id="SALE_RATE_C"></span>
				</td>
				<td width="10%" class="tbYellow">進駐率</td>
				<td align="left"  width="23%" class="tbYellow2" >
					<span id="REST_RATE_C"></span>
				</td>
				<td width="10%" class="tbYellow">交通機能</td>
				<td align="left" width="24%" class="tbYellow2">
					<span id="TRFC_FUNC_C"></span>
				</td>											
			</tr>
			<tr class="tbYellow">
				<td class="tbYellow">生活機能</td>
				<td align="left" class="tbYellow2">
					<span id="LIFE_FUNC_C"></span>
				</td>
				<td class="tbYellow">管理情形</td>
				<td align="left" class="tbYellow2" colspan="3">
					<span id="MANAGE_STATUS_C"></span>
				</td>							
			</tr>			
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_J">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<a href="#A_div_GridJ" id="A_div_GridJ">
						<strong>二、影像顯示</strong>
					</a>
				</td>
			</tr>	
			<tr>
				<td>
					<div id="div_GridJ" style="overflow-y:hidden; overflow-x:hidden; display:none;">
						<iframe id="DSA33308" name="DSA33308" width="100%" height="640" frameborder="0" src=""></iframe>
					</div>
				</td>
			</tr>
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_G">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>三、環境資料</strong>
				</td>
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow" width="10%" >嫌惡設施</td>
				<td align="left" class="tbYellow2" colspan="5"  width="90%">
					<span id="DISLIKE_LIST"></span><br>
					<textarea rows=3 cols=80 id="DISLIKE_DESC_VIEW" readonly class="textAreaOldSys checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow" width="10%">環境設施</td>
				<td align="left" class="tbYellow2" colspan="5"  width="90%">
					<span id="SPC_LIST"></span><br>
					<textarea rows=3 cols=80 id="SPC_DESC_VIEW" readonly class="textAreaOldSys checkInputLength" maxLength="500" onkeyup="if(this.scrollHeight > 50) this.style.posHeight=this.scrollHeight"></textarea>
				</td>
			</tr>		
			<tr class="tbYellow">
				<td class="tbYellow" width="10%">捷運說明</td>
				<td align="left" class="tbYellow2" colspan="5" width="90%">
					<span id="MRT_DESC"></span>
				</td>
			</tr>	
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_H">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>四、土地資料</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="6">			
					<table id="gridH">
					</table>			
				</td>
			</tr>
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_E">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>五、車位資料</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="6">			
					<table id="gridE">
					</table>			
				</td>
			</tr>
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_F">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>車位資料清單</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="6">			
					<table id="gridF">
					</table>			
				</td>
			</tr>			
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_K">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="8">
					<strong>六、價格資料(近兩年)</strong>
				</td>
			</tr>	
			<tr class="tbYellow">
				<td class="tbYellow" width="10%">鑑估紀錄</td>
				<td align="left" class="tbYellow2" width="15%">
					<span id="VALUATION_1"></span>
				</td>
				<td class="tbYellow" width="10%">實價登錄</td>
				<td align="left" class="tbYellow2" width="15%">
					<span id="VALUATION_2"></span>
				</td>
				<td class="tbYellow" width="10%">社區價格</td>
				<td align="left" class="tbYellow2" width="15%">
					<span id="VALUATION_4"></span>
				</td>										
			</tr>
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="8">
					<strong>鑑估紀錄清單</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="8">			
					<table id="gridK1">
					</table>			
				</td>
			</tr>	
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="8">
					<strong>實價登錄清單</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="8">			
					<table id="gridK2">
					</table>			
				</td>
			</tr>	
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_D">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>七、建物列管</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="6">			
					<table id="gridD">
					</table>			
				</td>
			</tr>
		</table>					
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_I">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<a href="#A_div_GridI" id="A_div_GridI"><strong>八、使照資料</strong></a>
				</td>
			</tr>	
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="6">	
					<div id="div_GridI" style="overflow:auto; display:none;">						
						<table id="gridI"></table>			
					</div>
				</td>
			</tr>
		</table>
		<table class="tbBox2" cellspacing="1" style="width:100%; border:0;" id="block_L">
			<tr align="center" class="tbYellow">
				<td class="tbYellow0" align="center" colspan="6">
					<strong>九、待售資料</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td class="tbYellow" align="center" colspan="6">			
					<table id="gridL">
					</table>			
				</td>
			</tr>
		</table>	
	</form>
</body>
</html>