<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!--
程式：DSA33301.jsp
作者：李明翰
功能：社區基本資料
完成：

[20221128]
1. 區塊B新增社區狀態欄位
2. 新增區塊D、區塊G
3. 區塊E新增欄位
高強禾

[20221209]問題單20221209132858
將區塊B新增、刪除按鈕移除
郭曉慧

[20221212]問題單20221212144849
查詢後若社區狀態為”已呈核”或”已覆核”則區塊B欄位都disable
修改新增卡控
    1. 若價格區間檢視若為”不符合”，價格落差原因不可為”無”
    2. 建案名稱不可與相同地號之其他社區的建案名稱相同
郭曉慧    

[20221214] 問題單: 20221214102533 陳勁谷
1.新增”匯入電子地圖”按鈕
2.初始查詢電子地圖有資料控制匯入電子地圖按鈕disable

[20230118] 修改件 陳勁谷 B區新增「充電樁設備」欄位，新增/修改SQL一併修正，外部單位使用者不顯示

[20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 
[20231031] 231020023853 承作區上線前置作業 
1. 經緯度改為disable欄位
2. 移除(註解)匯入電子地圖按鈕
[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間

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
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>

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
Event.observe(window, 'load', new DSA33301().initApp);

<%-- 供DSA33390.jsp檢核欄位使用 --%>
function DSA33301_validation(){
	var valid = new Validation('form1', {useTitles:false});
	
	Validation.addAllThese([
		['validateBetween1', '最高公設比小於最低公設比，請重新檢視', function(v , node) { 
			var lower = parseFloat($F('PUB_RATE_LOWER'));
			var upper = parseFloat($F('PUB_RATE_UPPER'));
			if(isNaN(lower)  || isNaN(upper) ){
				return true ;
			}else{
				return upper >= lower ;
			}
		}],	
		['validateNum0To99', '', function(v , node) {  <%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
			return v >= 0 && v <= 99;
		}],
		['checkAfterDot','', function(v , node) { <%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
			return checkNumeralFormat(v,2,2);
		}],
		['checkUSE_FOR','', function(v , node) { <%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
            return !Validation.get('IsEmpty').test(v) && v != 0;
		}]
	]);
	
	valid.define( "required" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比不得為空" });
	valid.define( "required" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設比不得為空" });
	valid.define( "validate-positive-number" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比請輸入有效正數" });
	valid.define( "validate-positive-number" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設比請輸入有效正數" });
	valid.define( "validateNum0To99" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比數值須於0~99內" });
	valid.define( "validateNum0To99" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設數值比須於0~99內" });
	valid.define( "checkAfterDot" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比數值須於小數點二位內" });
	valid.define( "checkAfterDot" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設比數值須於小數點二位內" });
	valid.define( "checkUSE_FOR" ,{ id :"USE_FOR", errMsg : "建築型態不可為空" });
	
	return valid.validate();
}

function DSA33301(){

	<%-- TablE UI物件 --%>
	var TOWN_Map = {};//儲存已查詢的鄉鎮
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3301/');	
	var FUNC_ID = 'DSA33301';
	var valid;
	var grid1;
	var grid2;
	
	<%-- [20221128] --%>
	var gridD;
	var gridG;
	
	<%-- 按鈕權限 --%>
	<%-- [20221209]移除按鈕權限 --%>
	
	<%--畫面檢核--%>
	function initValidation(){
		valid = new Validation('form1', {useTitles:false});		

		Validation.addAllThese([
		    ['validLength10', '長度最多為10', function(v , node) { 
				return commonTools.checkLength(v, 10);
		    }],
		    ['validLength20', '長度最多為20', function(v , node) { 
				return commonTools.checkLength(v, 20);
		    }],
		    ['validLength30', '長度最多為30', function(v , node) { 
				return commonTools.checkLength(v, 30);
		    }],
		    ['validLength40', '長度最多為40', function(v , node) { 
				return commonTools.checkLength(v, 40);
		    }],
		    ['validLength60', '長度最多為60', function(v , node) { 
				return commonTools.checkLength(v, 60);
		    }],
			['validateBetween1', '最高公設比小於最低公設比，請重新檢視', function(v , node) { 
				var lower = parseFloat($F('PUB_RATE_LOWER'));
				var upper = parseFloat($F('PUB_RATE_UPPER'));
				if(isNaN(lower)  || isNaN(upper) ){
					return true ;
				}else{
					return upper >= lower ;
				}
			}],	
			['validateBetween2', '社區價格區間迄值不得小於起值', function(v , node) { 
				var lower = parseFloat($F('VALUATION_4_LOW'));
				var upper = parseFloat($F('VALUATION_4_HIGH'));
				if(isNaN(lower)  || isNaN(upper) ){
					return true ;
				}else{
					return upper >= lower ;
				}
			}],
			['validateNum0To99', '', function(v , node) {  <%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
				return v >= 0 && v <= 99;
			}],
			['checkAfterDot','', function(v , node) { <%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
				return checkNumeralFormat(v,2,2);
			}],
			['checkUSE_FOR','', function(v , node) { <%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
	            return !Validation.get('IsEmpty').test(v) && v != 0;
			}]
		]);
		<%--[20221212]移除相似社區--%>
		valid.define( "validate-digits" ,{ id : "FLOOR", errMsg : "總樓層請輸入有效正整數" });
		valid.define( "validLength20" , { id:"ROAD_NAME" , errMsg : "正面路名長度最多為20碼" } );
		valid.define( "validLength30" , { id:"LICENSE_NO" , errMsg : "使照號碼長度最多為30碼" } );
		valid.define( "validLength40" , { id:"CASE_NAME" , errMsg : "建案名稱長度最多為40碼" } );
		valid.define( "required" , { id:"CASE_NAME" , errMsg : "請輸入建案名稱" } );
		valid.define( "required" , { id:"CITY" , errMsg : "請選擇縣市" } );
		valid.define( "required" , { id:"DIST" , errMsg : "請選擇鄉鎮市區" } );
		valid.define( "required" , { id:"LONGITUDE" , errMsg : "請輸入經度" } );
		valid.define( "required" , { id:"LATITUDE" , errMsg : "請輸入緯度" } );
		valid.define( "required" , { id:"ADDR_NO" , errMsg : "請輸入地址" } );
		valid.define( "required" , { id:"FLOOR" , errMsg : "請輸入總樓層" } );
		valid.define( "required" , { id:"HOUSE_NO" , errMsg : "請輸入使照戶數" } );
		valid.define( "validate-selection" , { id:"USE_FOR" , errMsg : "請輸入建築型態" } );
		valid.define( "validLength60" , { id:"ADDR_NO" , errMsg : "地址長度最多為60碼" } );
		valid.define( "validate-digits" ,{ id : "HOUSE_NO", errMsg : "使照戶數請輸入有效正整數" });
		valid.define( "validate-positive-number" ,{ id :"ROAD_WIDTH", errMsg : "正面路寬請輸入有效正數" });
		<%-- [20230630] 【修改】調整公設比最大最小以及建築形態檢核規則 --%>
		valid.define( "required" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比不得為空" });
		valid.define( "required" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設比不得為空" });
		valid.define( "validate-positive-number" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比請輸入有效正數" });
		valid.define( "validate-positive-number" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設比請輸入有效正數" });
		valid.define( "validateNum0To99" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比數值須於0~99內" });
		valid.define( "validateNum0To99" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設數值比須於0~99內" });
		valid.define( "checkAfterDot" ,{ id :"PUB_RATE_LOWER", errMsg : "最低公設比數值須於小數點二位內" });
		valid.define( "checkAfterDot" ,{ id :"PUB_RATE_UPPER", errMsg : "最高公設比數值須於小數點二位內" });
		valid.define( "checkUSE_FOR" ,{ id :"USE_FOR", errMsg : "建築型態不可為空" });
		<%--[20221209]社區價格區間必輸--%>
		valid.define( "required" ,{ id :"VALUATION_4_LOW", errMsg : "社區價格區間請輸入" });
		valid.define( "required" ,{ id :"VALUATION_4_HIGH", errMsg : "社區價格區間請輸入" });
		valid.define( "validate-positive-number" ,{ id :"VALUATION_4_LOW", errMsg : "社區價格區間請輸入有效正數" });
		valid.define( "validate-positive-number" ,{ id :"VALUATION_4_HIGH", errMsg : "社區價格區間請輸入有效正數" });
		valid.define( "validate-number" ,{ id : "LONGITUDE", errMsg : "經度請輸入有效數字格式"});		
		valid.define( "validate-number" ,{ id : "LATITUDE", errMsg : "緯度請輸入有效數字格式"});		
		valid.define( "validateBetween1" , { id:"PUB_RATE_UPPER"} );
		valid.define( "validateBetween2" , { id:"VALUATION_4_HIGH"} );
	}

	var buttons = {
		handleButtonEnable : function(status) {
			<%--[20221209]移除新增/刪除--%>
			if(status == 'NEW'){
				$('btnModify').disable();		
				$('CITY').enable();		
				$('DIST').enable();		
			}else if(status == 'UPDATE'){
				$('btnModify').enable();
				<%--因為代號是根據縣市與鄉鎮而來，因此修改時不該讓使用者修改縣市與鄉鎮--%>
				$('CITY').disable();		
				$('DIST').disable();		
			}	
		}
	};
	
	
	var actions = {
		<%--起始畫面--%>
		initLayout : function() {
			$('CITY').observe('change' , actions.onCityChange);	
			<%--[20221209]移除新增/刪除--%>
			$('btnModify').observe('click' , actions.modify);
			$('FINISH_DATE').observe('change' , actions.resetHouseAge);	
			<%--[20221213]社區價格區間連動--%>
			$w('VALUATION_4_LOW VALUATION_4_HIGH').each(function(ele){
				$(ele).observe('change' , actions.chgVALUATION);	
			});
			<%--[20221214] 問題單: 20221214102533 陳勁谷 新增”匯入電子地圖”按鈕
			$('btnImportMap').observe('click' , actions.doImportMap);
			--%>
		},
		chgVALUATION: function(){ <%--[20221213]社區價格區間連動--%>
			if($F('VALUATION_4_LOW').blank() || $F('VALUATION_4_HIGH').blank()){
				return;
			}
			var dataMap = gridD.getAllRecords()[0];
			dataMap.VALUATION_LOW = $F('VALUATION_4_LOW');
			dataMap.VALUATION_HIGH = $F('VALUATION_4_HIGH');
			ajaxRequest.post('chgVALUATION', {'dataMap' : Object.toJSON(dataMap)},
				function(resp){ 
					gridD.load(resp.dataMap || []);
				}
			);
		},
		<%--當修改用所得格式改變，用在啟始時或者下拉選單被選擇時使用--%>			
		onCityChange : function() {
			var selectElement = $('DIST');
			selectElement.length = 1;
			var val = $F('CITY') ;
			if(!val){
				return;
			}
			<%--已查詢過就不用再做查詢--%>
			if(TOWN_Map[val]&&TOWN_Map[val].length > 0){
				var opts = TOWN_Map[val];
				commonTools.createOptions(selectElement,opts,'POSTCODE','TOWN_NAME');			
			}else{
				ajaxRequest.post('getTownList', { 
					CITY_NAME : val							
				},
				function(resp){ 
					var opts = resp.TOWN_LIST;
					TOWN_Map[val] = opts;
					commonTools.createOptions(selectElement,opts,'POSTCODE','TOWN_NAME');			
				});					
			}
		},		
		<%--新增--%>
		<%--[20221209]移除新增--%>
		<%--修改--%>
		modify : function() {
			valid.reset();
			if(!valid.validate()){
				return;
			}
			<%--先檢查有無相似社區不存在，再進行修改--%>	
			<%--[20221212]移除相似社區--%>
			actions.doModify()
		},	
		<%--真正的修改行為--%>
		doModify : function() {		
			ajaxRequest.post('modify', { 
				'DATA_OBJ' : Object.toJSON(commonTools.createCommunityObj(false)),
				'COMMUNITY_NO' : $('COMMUNITY_NO').innerHTML,
				<%-- [20221128] --%>
				'DATA_D' : Object.toJSON(gridD.getAllRecords()),
				'DATA_G' : Object.toJSON(gridG.getAllRecords())
			},
			function(resp){ 
				if(resp.COMMUNITY_INFO){
					actions.reloadObj(resp.COMMUNITY_INFO);
				}
				
				<%-- [20221128] --%>
				var A349Map = resp.A349Map || {};
				actions.setStatusName(A349Map);
				actions.setBlockEData(resp.priceMap || {});
				gridD.load(resp.A349Map || []);
				gridG.load(resp.A349List || []);
				
				<%--修改成功，將按鈕狀態改為更新模式--%>
				buttons.handleButtonEnable('UPDATE');
				<%--[20221213]預設不可編輯--%>
				actions.setReadOnly(true);
				if(A349Map.STATUS == '1'){
					actions.setReadOnly(false);
				}
				var commInfo = resp.COMMUNITY_INFO;
				<%--[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>
				var IS_PUBLIC_CONFIRM = commInfo.IS_PUBLIC_CONFIRM || '';

				actions.checkPublicConfirm(IS_PUBLIC_CONFIRM);
				
			}
			);
		},
		<%--刪除--%>
		<%--[20221209]移除刪除--%>
		<%--社區搜尋，加入suggestion裡面--%>
		<%--[20221212]移除相似社區--%>
		<%--[20221212]移除取得所有相似社區的中文--%>
		<%--[20221128] 設定社區狀態 --%>
		setStatusName : function(dataObj) {
			$('STATUS_NM').update(dataObj.STATUS_NM || '');
		},
		setReadOnly: function(isReadOnly){ <%--[20221213]設定畫面是否可編輯--%>
			if(isReadOnly){
				$('block_A').select('input', 'select').each(function(ele){
					$(ele).disable();
				});
				$('gridD').select('input[key=DIFF_MEMO]', 'select[key=DIFF_REASON]').each(function(ele){
					ele.disable();
				});
				$('gridG').select('input[key=MA_MEMO]', 'select[key=MA_KD]').each(function(ele){
					$(ele).disable();
				});
				$('btnModify').disable();
			}else{
				$('block_A').select('input', 'select').each(function(ele){
					$(ele).enable();
				});
				$('gridD').select('input[key=DIFF_MEMO]', 'select[key=DIFF_REASON]').each(function(ele){
					$(ele).enable();
				});
				$('gridG').select('input[key=MA_MEMO]', 'select[key=MA_KD]').each(function(ele){
					$(ele).enable();
				});
				$('btnModify').enable();
				<%-- [20231031] 承作區上線前調整 經緯度改為disabled--%>
				$('LONGITUDE').disable();				
				$('LATITUDE').disable();
				<%-- [20231113] 承作區上線前調整 依郁晴需求，生活圈改為disabled--%>
				$('SUBMKT_NAME').disable();
			}
		},
		<%--[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>
		checkPublicConfirm : function(IS_PUBLIC_CONFIRM) {
			var putlicConfirm = $('PUBLIC_CONFIRM');
			if(IS_PUBLIC_CONFIRM =='Y'){
				putlicConfirm.enable();
			}else{
				putlicConfirm.disable();
			}
		},
		<%-- [20221128] 設定E區資料 --%>
		setBlockEData : function(dataObj) {
			
			<%-- [20221128] --%>
			var spanList = ['VALUATION_2','VALUATION_1','PRE_VALUATION'];
			commonTools.startReload(spanList, dataObj, 'span', '' );
			
			var spanDateList = ['PRE_CONFIRM_TIME']
			commonTools.startReload(spanDateList, dataObj, 'spanDate', '' );
		},
		<%--重整畫面--%>		
		reloadObj : function(dataObj){
			var selectionList = ['CITY','BASEMENT_FLOOR','MATERIAL','USE_FOR','SALE_RATE','REST_RATE',
			                     'LIQUE_AREA','MANAGE_STATUS','LIFE_FUNC','TRFC_FUNC','TAKE_OVER']
			commonTools.startReload(selectionList, dataObj, 'select', '0' );
			
			var selectionList1 = ['IS_PUBLIC']
			commonTools.startReload(selectionList1, dataObj, 'select', '' );
		
			<%--重新設定text的內容--%>
			<%--[20220718]增加次分區欄位--%>	
			<%--[20221212] 移除相似社區相關欄位COMMUNITY_SLI* --%>
			<%--[20230118] 修改件 陳勁谷 B區新增「充電樁設備」欄位，新增/修改SQL一併修正，外部單位使用者不顯示--%>
			<%--[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>	
			var textList = ['CASE_NAME','ADDR_NO','FLOOR','LICENSE_NO','ROAD_NAME','ROAD_WIDTH','HOUSE_NO',
							'PUB_RATE_LOWER','PUB_RATE_UPPER','LONGITUDE','LATITUDE','VALUATION_4_HIGH','VALUATION_4_LOW',
							'COMMUNITY_NO','APPLY_ID','SUBMKT_NAME', 'CHARGING', 'PUBLIC_CONFIRM']
			commonTools.startReload(textList, dataObj, 'text', '' );
			
			<%--重新設定日期的內容--%>				
			var dateList = ['FINISH_DATE','UPDATE_PIC_DATE']
			commonTools.startReload(dateList, dataObj, 'date', '' );

			<%--重新設定span的內容--%>				
			<%-- [20221128] 因資料來源改變，移除VALUATION_2 --%>
			<%-- [20221212] 移除CREATE_INFO --%>
			var spanList = ['COMMUNITY_NO','RESTRICT_AREA','PRE_INFO']
			commonTools.startReload(spanList, dataObj, 'span', '' );

			<%--重新設定span date的內容--%>				
			//var spanList = ['UPDATE_DATE']
			//commonTools.startReload(spanList, dataObj, 'spanDate', '' );
			
			<%--設定土壤液化等級定位(電子地圖)的值--%>
			$('MAP_LIQUE_AREA').innerHTML=dataObj.MAP_LIQUE_AREA ? '地圖參考：'+dataObj.MAP_LIQUE_AREA : '';
			
			<%--設定社區相簿最新日期(電子地圖)的值--%>
			$('ALBUM_NAME').innerHTML=dataObj.ALBUM_NAME ? '社區最新相簿：'+dataObj.ALBUM_NAME : '';
			
			<%--設定社區編號的值--%>				
			//$('H_COMMUNITY_NO').value = dataObj.COMMUNITY_NO || '';
			
			<%--設定鄉鎮市區的值--%>				
			$('DIST').value = dataObj.POSTCODE || '';
			
			<%--設定屋齡的值--%>				
			actions.resetHouseAge(dataObj.FINISH_DATE);
			
			<%--重新設定相似社區的連結--%>	
			<%--[20221212]移除相似社區--%>
		},	
		<%--點選link的行為--%>	
		doLinkToDSA3_3310 : function(communityNO){
			return function(){				
				<%--設定社區編號的值--%>	
				$('H_COMMUNITY_NO').setValue(communityNO);
		    	document.form1.action = "${dispatcher}/DSA3_3310/prompt";
		    	document.form1.target = "_blank";
		    	submitOnce($('form1'));
			}
		},
		<%--重新計算屋齡--%>	
		resetHouseAge : function(){			
			ajaxRequest.post('getHouseAge', { 
				'IPT_DATE' : $F('FINISH_DATE')
			},
			function(resp){ 
				commonTools.setValue($('BUILD_AGE'), resp.HOUSE_AGE || '' , 'span', '');
			});
		},
		<%--[20221214] 問題單: 20221214102533 陳勁谷 新增”匯入電子地圖”按鈕
		doImportMap : function() {
			ajaxRequest.post('importMap', { 
				COMMUNITY_NO: $('COMMUNITY_NO').innerHTML
			},
			function(resp){
				$('btnImportMap').disable();
			})
		}
		--%>
	};	
		
	var commonTools = {
		<%--將map設定為select的下拉選單內容--%>		
		createOptions:function(selectElement, opts, keyName , textName){
			if(opts){
				opts.each(function(opt){
					selectElement.insert(new Element('option', {value: opt[keyName]}).update(opt[textName]));
				});
			}
		},		
		<%--加入suggestion--%>	
		<%--[20221212]移除相似社區--%>
		<%--產生要送出的資料object--%>
		createCommunityObj:function(isCreate){
			var obj = {
				'CASE_NAME' : $F('CASE_NAME'),					
				'ADDR_NO' : $F('ADDR_NO'),					
				'FLOOR' : $F('FLOOR'),					
				'BASEMENT_FLOOR' : $F('BASEMENT_FLOOR'),
				'TAKE_OVER' : $F('TAKE_OVER'),				
				'LICENSE_NO' : $F('LICENSE_NO'),					
				'FINISH_DATE' : $F('FINISH_DATE'),					
				'MATERIAL' : $F('MATERIAL') || '0',					
				'ROAD_NAME' : $F('ROAD_NAME'),					
				'ROAD_WIDTH' : $F('ROAD_WIDTH'),	
				'HOUSE_NO' : $F('HOUSE_NO'),					
				'PUB_RATE_LOWER' : $F('PUB_RATE_LOWER'),					
				'PUB_RATE_UPPER' : $F('PUB_RATE_UPPER'),					
				'USE_FOR' : $F('USE_FOR') || '0',		
				'UPDATE_PIC_DATE' : $F('UPDATE_PIC_DATE'),					
				'SALE_RATE' : $F('SALE_RATE'),					
				'REST_RATE' : $F('REST_RATE'),					
				'LONGITUDE' : $F('LONGITUDE'),					
				'LATITUDE' : $F('LATITUDE'),					
				'LIQUE_AREA' : $F('LIQUE_AREA'),					
				'MANAGE_STATUS' : $F('MANAGE_STATUS'),					
				'LIFE_FUNC' : $F('LIFE_FUNC'),					
				'TRFC_FUNC' : $F('TRFC_FUNC'),		
				'VALUATION_4_LOW' : $F('VALUATION_4_LOW'),	
				'VALUATION_4_HIGH' : $F('VALUATION_4_HIGH'),
				<%--[20221212]移除相似社區--%>
				'IS_PUBLIC' : $F('IS_PUBLIC'),
				'SUBMKT_NAME' : $F('SUBMKT_NAME'),<%--[20220718]增加次分區欄位--%>
				'CHARGING' : $F('CHARGING'),<%--[20230118] 修改件 陳勁谷 B區新增「充電樁設備」欄位，新增/修改SQL一併修正，外部單位使用者不顯示--%>
				'PUBLIC_CONFIRM' : $("PUBLIC_CONFIRM").checked ? 1: 0<%--[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>
			};
			<%--只有新增才能寫入city跟dist--%>
			if(isCreate){
				obj['CITY'] = $F('CITY'),	
				obj['DIST'] = $('DIST').options[$('DIST').selectedIndex].text,
				obj['POSTCODE'] = $F('DIST')
			}
			return obj;
		},
		<%--reload用的把資料寫入畫面--%>
		startReload : function(fields, dataObj , fieldType, defaultValue){
			for(var i = 0 ; i < fields.length ; i++){
				var field = fields[i];
				commonTools.setValue($(field), dataObj[field], fieldType, defaultValue);
			}
		},
		<%--根據不同種類，取得default值，並且寫入欄位--%>
		setValue : function(field, value, fieldType, defaultValue){
			if(!value){			
				if('text' == fieldType || 'span' == fieldType){
					value = defaultValue;
				}else if('select' == fieldType){
					value = field[0].value ? field[0].value : defaultValue;
				}
			}
			if('text' == fieldType){
				var field_id = field.id;
				if(field_id == 'PUB_RATE_LOWER' || field_id == 'PUB_RATE_UPPER') {
					field.value = value || 0;
				} else {
					field.value = value;
				}
				<%--[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>
				if(field_id == 'PUBLIC_CONFIRM'){
					if(field.value == '1'){
						field.checked = true;
					}else{
						field.checked = false;
					}
				}
			}else if('span' == fieldType){
				field.innerHTML = value;
			}else if('spanDate' == fieldType){
				field.innerHTML = Date.toROC(value);
			}else if('select' == fieldType){
				field.value = value; 
			}else if('date' == fieldType){
				field.value = Date.toInputROC(value);
			}
		},		
		<%--產生span的連結--%>
		createLink : function(linkValue, submitData, spanField){
			if(spanField.hasChildNodes()){
				spanField.removeChild(spanField.lastChild);
			}
			if(linkValue){
				var link = new Element( 'a' , { href : '#' } ).update(linkValue);									
				link.observe('click', actions.doLinkToDSA3_3310(submitData));	
				spanField.insert(link);
			}
			
		},
		<%--檢核長度--%>		
		checkLength : function(str, maxLength) {
			if(commonTools.getChtLength(str) > maxLength){
				return false;
			}
			return true;
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
			<cathay:LocaleDisplay sysCode='DS' dateFields="UPDATE_PIC_DATE FINISH_DATE" var='localeDisplay' />				
			PageUI.createPageWithAllBodySubElement(
					'DSA33301',
					'鑑價作業',
					'基本資料',
					'',
					true
				);
			grid1 = new TableUI({
			 	table: $("grid1"),
				pageSize:0, 
				column:[	
					{header:"社區編號", key:'COMMUNITY_NO', attrs : { Width : '10%'}},						
					{header:"建案名稱", key:'CASE_NAME', attrs : { Width : '10%'}},
					{header:"縣市", key:'CITY', attrs : { Width : '8%'}},					
					{header:"鄉鎮市區", key:'DIST', attrs : { Width : '8%'}},
					{header:"建築完成日", key:'FINISH_DATE', attrs : { Width : '8%'}, sortRule:'date'},
					{header:"段名", key:'LOCATION2', attrs : { Width : '10%'}},					
					{header:"小段名", key:'LOCATION3', attrs : { Width : '10%'}},						
					{header:"地號1", key:'LAND_NO1', attrs : { Width : '8%'}},					
					{header:"地號2", key:'LAND_NO2', attrs : { Width : '8%'}},
					{header:'地址(代表號)', key:"ADDR_NO" , styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						input:{type:'SHOW', shortTextLength: 10, easyEdit:true, attrs: {alt: "ch"}}<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					},
				]
			});
			grid2 = new TableUI({
			 	table: $("grid2"),
				pageSize:0, 
				column:[	
					{header:"地址", key:'ADDR_NO', attrs : { Width : '40%'}, styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					{header:"成交日期", key:'TRADE_DATE', attrs : { Width : '10%'}, sortRule:'date'},
					{header:"樓層別", key:'FLOOR', attrs : { Width : '10%'}},					
					{header:"建坪(不含車位面積)(坪)", key:'BUILD_MEASURE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"建坪單價(不含車位面積)(萬/坪)", key:'PER_PRICE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"車位總面積(坪)", key:'PARK_MEASURE', attrs : { Width : '10%'}, sortRule:'number'},		
					{header:"車位總價(萬)", key:'PARK_T_PRICE', attrs : { Width : '10%'}, sortRule:'number'},
					{header:"車位型態", key:'PARK_TYPE', attrs : { Width : '10%'}}// 2021鑑價作業優化 新增車位型態欄位
				]
			});
			
			<%-- [20221128] --%>
			gridD = new TableUI({
			 	table: $("gridD"),
				pageSize:0, 
				column:[	
					{header:"社區價格(萬/坪)", key:'VALUATION'},						
					{header:"價格區間檢視", key:'PRICE_AREA_VIEW'},
					{header:"價格落差原因", key:'DIFF_REASON',
						input:{
							type:'SELECT',
							opts:<c:out value="${PRICE_DIFF_REASON_LIST}" escapeXml="false" default='{}' />
						}
					},					
					{header:"說明備註", key:'DIFF_MEMO',
						input:{
							type:'TEXT', maxlength:100
						}
					}
				]
			});
			
			gridG = new TableUI({
			 	table: $("gridG"),
				pageSize:0, 
				column:[	
					{header:"維護項目", key:'MA_KD',
						input:{
							type:'SELECT',
							opts:<c:out value="${MAINTAIN_STATUS_LIST}" escapeXml="false" default='{}' />,
							genRule:function(record, value) {
								return record.IS_LAST == 'Y' && record.STATUS == '1';
							}
						},
						render: function(record, value) { // 非輸入模式時的處理
							return record.MA_KD_NM;
						}
					},						
					{header:"備註說明", key:'MA_MEMO',
						input:{
							type:'TEXT',
							genRule:function(record, value) {
								return record.IS_LAST == 'Y' && record.STATUS == '1';
							}
						},
						render:function(record, value) { // 非輸入模式時的處理
							return value;
						}
					},
					{header:"建置/維護人員", key:'UPDATE_NM', styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>				
					{header:"建置/維護日期", key:'UPDATE_DATE', sortRule : 'date'},
					{header:"覆核人員", key:'CONFIRM_NM', styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					{header:"維護覆核日期", key:'CONFIRM_DATE', sortRule : 'date'}
				]
			});

			<%-- [20221209]移除按鈕權限 --%>
			PageUI.resize();
			displayMessage();		
			initValidation();
			actions.initLayout();
			buttons.handleButtonEnable('${INIT_TYPE}');
			
			<%-- [20221212]移除suggestALL --%>
			actions.reloadObj(<c:out value="${COMMUNITY_INFO}" escapeXml="false" default="{}" />);
			grid1.load(<c:out value="${A350ListMap}" escapeXml="false" default='[]' />);
			grid2.load(<c:out value="${A263ListMap}" escapeXml="false" default='[]' />);
			
			<%-- [20221128] --%>
			var A349Map = <c:out value="${A349Map}" escapeXml="false" default="{}" />;
			actions.setStatusName(A349Map);
			actions.setBlockEData(<c:out value="${priceMap}" escapeXml="false" default="{}" />);
			gridD.load(A349Map);
			gridG.load(<c:out value="${A349List}" escapeXml="false" default='[]' />);
			<%--[20221213]預設不可編輯--%>
			actions.setReadOnly(true);
			if(A349Map.STATUS == '1'){
				actions.setReadOnly(false);
			}
			<%--[20221214] 問題單: 20221214102533 陳勁谷 2.初始查詢電子地圖有資料控制匯入電子地圖按鈕disable
			var controlImportMap = '${controlImportMap}' || '';
			if (controlImportMap == 'Y') {
				$('btnImportMap').enable();
			}
			--%>
			<%--[20240422] SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>
			var commInfo = ${COMMUNITY_INFO};
			var IS_PUBLIC_CONFIRM = commInfo.IS_PUBLIC_CONFIRM;
			actions.checkPublicConfirm(IS_PUBLIC_CONFIRM);
		}	
	};	
}	
	
</script>
</head>
<body>
	<form name='form1' id='form1' style='PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px'>
		<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
			<tr>
				<td class="tbYellow">縣市</td>
				<td class="tbYellow2">
					<select id="CITY" name="CITY" class="textBox2">
						<option value="">縣市別</option>
						<c:forEach var="map" items="${CITY_LIST}" >
							 <option value = "${map.CITY_NAME}" > ${map.CITY_NAME} </option>
						</c:forEach>
					</select> 
					<input type="hidden" id="APPLY_ID" name="APPLY_ID" value="">
				</td>
				<td class="tbYellow">鄉鎮市區</td>
				<td class="tbYellow2">
					<select id="DIST" name="DIST"  class="textBox2">
						<option value="">鄉鎮市區</option>
						<c:forEach var="map" items="${TOWN_LIST}" >
							 <option value = "${map.POSTCODE}"> ${map.TOWN_NAME} </option>
						</c:forEach>						
					</select> 
				</td>
				<td class="tbYellow">建案名稱</td>
				<td class="tbYellow2">
					<input name="CASE_NAME" id="CASE_NAME" size="15" maxLength="20" type="text" class="textBox2">
				</td>
			</tr>		
			<tr>
				<td class="tbYellow">地址(代表號)</td>
				<td class="tbYellow2">
					<input name="ADDR_NO" id="ADDR_NO" size="60" maxLength="60" type="text" class="textBox2" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</td>
				<td class="tbYellow">接手性</td>
				<td class="tbYellow2">
					<select id="TAKE_OVER" name="TAKE_OVER" class="textBox2">
						<c:forEach var="map" items="${TAKE_OVER_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<%--[20220330]新增國宅社區欄位--%>
				<c:if test="${!IS_BANK_USER}" >
					<td class="tbYellow">國宅社區</td>
					<td class="tbYellow2">
						<select id="IS_PUBLIC" name="IS_PUBLIC" class="textBox2">
						    <option value = ""></option>
							<c:forEach var="map" items="${IS_PUBLIC_LIST}" >
							 	<option value = "${map.key}"> ${map.value} </option>
							</c:forEach>
						</select> 
					</td>
				</c:if>
			</tr>				
			<tr>
				<td class="tbYellow">總樓層</td>
				<td class="tbYellow2">
					<input name="FLOOR" id="FLOOR" size ="5" type="text" class="textBox2">
				</td>
				<td class="tbYellow">地下層</td>
				<td class="tbYellow2">
					<select id="BASEMENT_FLOOR" name="BASEMENT_FLOOR" class="textBox2">
						<c:forEach var="map" items="${BASEMENT_FLOOR_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow">列管區</td>
				<td class="tbYellow2">
					<span id="RESTRICT_AREA" name="RESTRICT_AREA"></span>	
				</td>
			</tr>		
			<tr>
				<td class="tbYellow">使照號碼</td>
				<td class="tbYellow2">
					<input name="LICENSE_NO" id="LICENSE_NO" type="text" class="textBox2">
				</td>
				<td class="tbYellow">建築完成日</td>
				<td class="tbYellow2">
					<input id="FINISH_DATE" name="FINISH_DATE" type="text" class="textBox2"/>
				</td>
				<td class="tbYellow">屋齡(年)</td>
				<td class="tbYellow2">
					<span id="BUILD_AGE" name="BUILD_AGE"></span>	
				</td>
			</tr>				
			<tr>
				<td class="tbYellow">主要構造</td>
				<td class="tbYellow2">
					<select id="MATERIAL" name="MATERIAL"  class="textBox2">
						<c:forEach var="map" items="${MATERIAL_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 				
				</td>
				<td class="tbYellow">正面路名</td>
				<td class="tbYellow2">
					<input id="ROAD_NAME" name="ROAD_NAME" size="15" type="text" class="textBox2"/>
				</td>
				<td class="tbYellow">正面路寬(m)</td>
				<td class="tbYellow2">
					<input name="ROAD_WIDTH" id="ROAD_WIDTH" size="8" type="text" class="textBox2">
				</td>
			</tr>	
			<tr>
				<td class="tbYellow">使照戶數</td>
				<td class="tbYellow2">
					<input name="HOUSE_NO" id="HOUSE_NO" size="8" type="text" class="textBox2">
				</td>
				<td class="tbYellow">公設比區間</td>
				<td class="tbYellow2">
					<input id="PUB_RATE_LOWER" name="PUB_RATE_LOWER" size="8" type="text" class="textBox2" />
					%~
					<input id="PUB_RATE_UPPER" name="PUB_RATE_UPPER" size="8" type="text" class="textBox2"/>
					%
					<%--[20240422]SN_240403011641 卡控智能鑑價科才可以編輯公設比區間--%>
					<input id="PUBLIC_CONFIRM" name = "PUBLIC_CONFIRM" type="checkbox"/>
				</td>
				<td class="tbYellow">建築型態</td>
				<td class="tbYellow2">
					<select id="USE_FOR" name="USE_FOR" class="textBox2" >
						<c:forEach var="map" items="${USE_FOR_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
			</tr>				
			<tr>
				<td class="tbYellow">外觀照日期</td>
				<td class="tbYellow2">
					<input name="UPDATE_PIC_DATE" id="UPDATE_PIC_DATE" type="text" class="textBox2">
					<span id="ALBUM_NAME" name="ALBUM_NAME"></span>
				</td>
				<td class="tbYellow">銷售率</td>
				<td class="tbYellow2">
					<select id="SALE_RATE" name="SALE_RATE" class="textBox2" >
						<c:forEach var="map" items="${SALE_RATE_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow">進駐率</td>
				<td class="tbYellow2">
					<select id="REST_RATE" name="REST_RATE" class="textBox2" >
						<c:forEach var="map" items="${SALE_RATE_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
			</tr>
			<tr>
				<td class="tbYellow">經度</td>
				<td class="tbYellow2">
					<input name="LONGITUDE" id="LONGITUDE" size="15" type="text" class="textBox2" disabled>
				</td>
				<td class="tbYellow">緯度</td>
				<td class="tbYellow2">
					<input name="LATITUDE" id="LATITUDE" size="15" type="text" class="textBox2" disabled>
				</td>
				<td class="tbYellow">土壤液化區</td>
				<td class="tbYellow2">
					<select id="LIQUE_AREA" name="LIQUE_AREA"  class="textBox2">
						<c:forEach var="map" items="${LIQUE_AREA_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
					<span id="MAP_LIQUE_AREA" name="MAP_LIQUE_AREA"></span>
				</td>
			</tr>											
			<tr>
				<td class="tbYellow">管理情形</td>
				<td class="tbYellow2">
					<select id="MANAGE_STATUS" name="MANAGE_STATUS" class="textBox2" >
						<c:forEach var="map" items="${MANAGE_STATUS_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow">生活機能</td>
				<td class="tbYellow2">
					<select id="LIFE_FUNC" name="LIFE_FUNC" class="textBox2" >
						<c:forEach var="map" items="${LIFE_FUNC_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow">交通機能</td>
				<td class="tbYellow2">
					<select id="TRFC_FUNC" name="TRFC_FUNC" class="textBox2" >
						<c:forEach var="map" items="${TRFC_FUNC_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
			</tr>	
			<tr>
				<td class="tbYellow">社區價格區間</td>
				<td class="tbYellow2">
					<input id="VALUATION_4_LOW" name="VALUATION_4_LOW" size="10" type="text" class="textBox2" />
					萬~
					<input id="VALUATION_4_HIGH" name="VALUATION_4_HIGH" size="10" type="text" class="textBox2"/>
					萬
				</td>
				<td class="tbYellow">社區編號</td>
				<td class="tbYellow2">
					<span id="COMMUNITY_NO" name="COMMUNITY_NO"></span>	
					<input id="H_COMMUNITY_NO" name="COMMUNITY_NO" type="hidden"/>
				</td>
				<c:if test="${!IS_BANK_USER}" >
					<td class="tbYellow">生活圈</td>
					<td class="tbYellow2">
						<input id="SUBMKT_NAME" name="SUBMKT_NAME" size="15" type="text" class="textBox2"/>
					</td>
				</c:if>
				<!--
				<td class="tbYellow">管制區</td>
				<td class="tbYellow2">
					<select  id="CONTROL_AREA" name="CONTROL_AREA" class="textBox2">							
						<c:forEach var="map" items="${CONTROL_AREA_LIST}" >
							<option value = "${map.key}"> ${map.value} </option>						
						</c:forEach>							
					</select>	
				</td>
				-->	
			</tr>	
			<%-- [20221212]移除相似社區 --%>			
			<%-- [20221128] 增加社區狀態 --%>
			<tr>
				<td class="tbYellow">社區狀態</td>
				<td class="tbYellow2" colspan="<c:if test="${IS_BANK_USER}" >5</c:if>">
					<span id="STATUS_NM"></span>
				</td>
				<%--[20230118] 修改件 陳勁谷 B區新增「充電樁設備」欄位，新增/修改SQL一併修正，外部單位使用者不顯示 --%>
				<c:if test="${!IS_BANK_USER}" >
					<td class="tbYellow">充電樁設備</td>
					<td class="tbYellow2" colspan="3">
						<select id="CHARGING" name="CHARGING" class="textBox2">
							<option value="">請選擇</option>			
							<c:forEach var="map" items="${CHARGING_LIST}" >
								<option value = "${map.key}"> ${map.value} </option>						
							</c:forEach>							
						</select>
					</td>
				</c:if>
			</tr>
			<tr>
				<td colspan="6" class="tbYellow2">
					<div id="PRE_INFO" style="float:left"></div>
					<%-- [20221212]移除CREATE_INFO --%>	
				</td>
			</tr>	
			<tr>
				<td colspan="6" align="center" class="tbYellow2">
					<!-- [20221209]移除新增/刪除 -->
					<button id="btnModify" name="btnModify" type="button" class="button" disabled>(1)修改</button>
					<%--[20221214] 問題單: 20221214102533 陳勁谷 新增”匯入電子地圖”按鈕 --%>
					<%--[20231031] 承作區上線前調整 移除 匯入電子地圖按鈕，原功能整合至[電子地圖]按鈕
					<button id="btnImportMap" name="btnImportMap" type="button" class="button" disabled>匯入電子地圖</button>
					 --%>
				</td>
			</tr>
			<tr align="center" class="tbYellow">
				<td colspan="6" class="tbYellow0" align="center">
					<strong>相同地號之其他社區</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<td colspan="6" class="tbYellow" align="center">			
					<table id="grid1">
					</table>			
				</td>
			</tr>	
			<%-- [20221128] 增加D區 --%>
			<tr align="center" class="tbYellow">
				<td colspan="6" class="tbYellow0" align="center">
					<strong>社區價格檢視</strong>
				</td>
			</tr>
			<tr align="center" class="tbYellow">
				<td colspan="6" class="tbYellow" align="center">
					<table id="gridD">
					</table>
				</td>
			</tr>
		<%-- [20221128] 因E區欄位增加至8個，比上面B區多，故切開成第二個table --%>
		</table>
		<table id='block_B' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
			<tr align="center" class="tbYellow">
				<%-- [20221128] colspan="6"改成8 --%>
				<td colspan="8" class="tbYellow0" align="center">
					<strong>價格資料<%-- [20221128] 修改文字 --%></strong>
				</td>
			</tr>	
			<tr class="tbYellow">
				<td class="tbYellow" style="width:12.5%">實價登錄(萬/坪)</td>
				<%-- [20221128] 移除colspan --%>
				<td align="left" class="tbYellow2" style="width:12.5%">
					<span id="VALUATION_2"></span>
				</td>
				<%-- [20221128] 增加欄位 --%>
				<td class="tbYellow" style="width:12.5%">鑑價紀錄(萬/坪)</td>
				<td align="left" class="tbYellow2" style="width:12.5%">
					<span id="VALUATION_1"></span>
				</td>
				<td class="tbYellow" style="width:12.5%">前次社區價格(萬/坪)</td>
				<td align="left" class="tbYellow2" style="width:12.5%">
					<span id="PRE_VALUATION"></span>
				</td>
				<td class="tbYellow" style="width:12.5%">前次維護日期</td>
				<td align="left" class="tbYellow2" style="width:12.5%">
					<span id="PRE_CONFIRM_TIME"></span>
				</td>
			</tr>	
			<tr align="center" class="tbYellow">
				<%-- [20221128] colspan="6"改成8 --%>
				<td colspan="8" class="tbYellow0" align="center">
					<strong>實價登錄清單</strong>
				</td>
			</tr>														
			<tr align="center" class="tbYellow">
				<%-- [20221128] colspan="6"改成8 --%>
				<td colspan="8" class="tbYellow" align="center">			
					<table id="grid2">
					</table>			
				</td>
			</tr>
			<%-- [20221128] 增加G區 --%>
			<tr align="center" class="tbYellow">
				<td colspan="8" class="tbYellow0" align="center">
					<strong>維護項目說明</strong>
				</td>
			</tr>
			<tr align="center" class="tbYellow">
				<td colspan="8" class="tbYellow" align="center">
					<table id="gridG">
					</table>
				</td>
			</tr>
		</table>
	</form>
</body>
</html>