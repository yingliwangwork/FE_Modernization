<%@ page language='java' contentType='text/html; charset=BIG5'%>
<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->

<!--
程式：DSA35000.jsp
作者：邱建禕
功能：自動估價模型作業
完成：2022/10/12
[20240925] 修改件 地址查詢取得社區案名與郵遞區號
[20241001] 修改件 CHROME瀏覽器難字調整 
[20250414] 修改件
1.增加受理編號鑑價紀錄
2.導入車位估價模型，基本資料頁簽增加顯示車位清單
3.增加【新增】車位按鈕
4.增加【修正】車位按鈕
5.增加【刪除】車位按鈕
6.模型結果增加「模型車位總價(萬)」及「模型評估總價(萬)」給所有使用者， MODEL3_AVG_PRICE(Model3平均價格) 調整授權給 1-1、2看
[20250424]問題單 20250424090750
USER 輸入 1.5  ，小數點會回撤變 15，他覺得不直覺，改成可輸入數字即可，不要回撤小數點，再用validation檢核一定要正整數，有異常的標註粉紅底 
[20250506]問題單號：20250506113153
車位數量比較多，沒有顯示車位編輯區塊，無法編輯
-->
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css' />
<%--[20241001]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
         url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/suggest.js'></script>	<%-- 搜尋提示用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/tabs.js'></script> <%-- 頁籤切換  --%>


<style>
td.tbYellow,td.tbYellow2{
	white-space:nowrap;
}
</style>
<script type='text/JavaScript'>
Event.observe(window, 'load', new DSA35000().initApp);

function DSA35000(){	
	var tabs;
	var grid;
	var valid;
	var gridA2;<%--[20250414]A2 區車位清單--%>
	var gridA3;<%--[20250414]A3 區車位編輯區--%>	
	var PARK_TYPE_Map = <c:out value="${PARK_TYPE_Map}" default="{}" escapeXml="false" />;
	var PARK_FLOOR_Map = <c:out value="${PARK_FLOOR_Map}" default="{}" escapeXml="false" />;

	<%-- 已查詢的鄉鎮市區清單 --%>
	var TOWN_Map = {};
	
	<%-- POI計算(tab2)欄位動態產生 --%>
	var poiKey = ['TRAFFIC','LIVING','C2_D01_1000','C2_E02_1000','C2_H01_1000','C2_H03_1000','C2_H04_1000','C2_H05_1000','C2_H06_1000','C2_I01_1000',
				  'C2_K05_1000','C2_K08_1000','C2_Y19_1000','C2_B02_1000','C2_B03_1000','C2_C01_1000','C2_C06_1000','C2_G03_1000','C2_G08_1000','C2_H02_1000',
				  'C2_H32_1000','C2_K01_1000','C2_K02_1000','C2_Y08_1000','C2_D01_1500','C2_E02_1500','C2_H01_1500','C2_H03_1500','C2_H04_1500','C2_H05_1500',
				  'C2_H06_1500','C2_I01_1500','C2_K05_1500','C2_K08_1500','C2_Y19_1500','C2_B02_1500','C2_B03_1500','C2_C01_1500','C2_C06_1500','C2_G03_1500',
				  'C2_G08_1500','C2_H02_1500','C2_H32_1500','C2_K01_1500','C2_K02_1500','C2_Y08_1500','C2_D01_2000','C2_E02_2000','C2_H01_2000','C2_H03_2000',
				  'C2_H04_2000','C2_H05_2000','C2_H06_2000','C2_I01_2000','C2_K05_2000','C2_K08_2000','C2_Y19_2000','C2_B02_2000','C2_B03_2000','C2_C01_2000',
				  'C2_C06_2000','C2_G03_2000','C2_G08_2000','C2_H02_2000','C2_H32_2000','C2_K01_2000','C2_K02_2000','C2_Y08_2000','C2_D01_MINDIST','C2_E02_MINDIST',
				  'C2_H01_MINDIST','C2_H03_MINDIST','C2_H04_MINDIST','C2_H05_MINDIST','C2_H06_MINDIST','C2_I01_MINDIST','C2_K05_MINDIST','C2_K08_MINDIST','C2_Y19_MINDIST',
				  'C2_B02_MINDIST','C2_B03_MINDIST','C2_C01_MINDIST','C2_C06_MINDIST','C2_G03_MINDIST','C2_G08_MINDIST','C2_H02_MINDIST','C2_H32_MINDIST','C2_K01_MINDIST',
				  'C2_K02_MINDIST','C2_Y08_MINDIST'];
	
	var poiFieldName = ['交通指數','生活指數','1000公尺內飯店旅館數量','1000公尺內銀行數量','1000公尺內百貨、購物中心數量','1000公尺內量販店數量','1000公尺內超市數量','1000公尺內便利商店數量',
						'1000公尺內連鎖藥妝店數量','1000公尺內速食店數量','1000公尺內捷運數量','1000公尺內捷運_尚未正式營運數量','1000公尺內高架橋數量','1000公尺內小學數量','1000公尺內中高級校數量',
						'1000公尺內地區醫院數量','1000公尺內區域醫院數量','1000公尺內電影院數量','1000公尺內公園數量','1000公尺內生活百貨數量','1000公尺內市場數量','1000公尺內國道設施數量',
						'1000公尺內鐵路設施數量','1000公尺內加油站數量','1500公尺內飯店旅館數量','1500公尺內銀行數量','1500公尺內百貨、購物中心數量','1500公尺內量販店數量','1500公尺內超市數量',
						'1500公尺內便利商店數量','1500公尺內連鎖藥妝店數量','1500公尺內速食店數量','1500公尺內捷運數量','1500公尺內捷運_尚未正式營運數量','1500公尺內高架橋數量',
						'1500公尺內小學數量','1500公尺內中高級校數量','1500公尺內地區醫院數量','1500公尺內區域醫院數量','1500公尺內電影院數量','1500公尺內公園數量','1500公尺內生活百貨數量',
						'1500公尺內市場數量','1500公尺內國道設施數量','1500公尺內鐵路設施數量','1500公尺內加油站數量','2000公尺內飯店旅館數量','2000公尺內銀行數量','2000公尺內百貨、購物中心數量',
						'2000公尺內量販店數量','2000公尺內超市數量','2000公尺內便利商店數量','2000公尺內連鎖藥妝店數量','2000公尺內速食店數量','2000公尺內捷運數量','2000公尺內捷運_尚未正式營運數量',
						'2000公尺內高架橋數量','2000公尺內小學數量','2000公尺內中高級校數量','2000公尺內地區醫院數量','2000公尺內地區醫院數量','2000公尺內電影院數量','2000公尺內公園數量',
						'2000公尺內生活百貨數量','2000公尺內市場數量','2000公尺內國道設施數量','2000公尺內鐵路設施數量','2000公尺內加油站數量','與飯店旅館在2000公尺內最短距離',
						'與銀行在2000公尺內最短距離','與百貨、購物中心在2000公尺內最短距離','與量販店在2000公尺內最短距離','與超市在2000公尺內最短距離','與便利商店在2000公尺內最短距離',
						'與連鎖藥妝店在2000公尺內最短距離','與速食店在2000公尺內最短距離','與捷運在2000公尺內最短距離','與捷運_尚未正式營運在2000公尺內最短距離','與高架橋在2000公尺內最短距離',
						'與小學在2000公尺內最短距離','與中高級校在2000公尺內最短距離','與地區醫院在2000公尺內最短距離','與區域醫院在2000公尺內最短距離','與電影院在2000公尺內最短距離',
						'與公園在2000公尺內最短距離','與生活百貨在2000公尺內最短距離','與市場在2000公尺內最短距離','與國道設施在2000公尺內最短距離','與鐵路設施在2000公尺內最短距離',
						'與加油站在2000公尺內最短距離'];
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_5000/');	

	function initValidation(){
		
		Validation.addAllThese([		
			['validateUSE_FOR','建物型態錯誤', 
			function(v){
				var USE_FOR_ARR = ['1','3','5','F','G'];
				if(USE_FOR_ARR.include(v)){
					return true;
				}
				return false;
			}],
			['validateBUILD_USAGE_ADJ','房屋用途錯誤', 
			function(v){
				var BUILD_USAGE_ADJ_ARR = ['1','4','5','6','9'];
				if(BUILD_USAGE_ADJ_ARR.include(v)){
					return true;
				}
				return false;
			}],
			['validateTRANS_FLOOR','僅限1樓以上擔保品', 
			function(v){
				if(v <= 1){
					return false;
				}
				return true;
			}],
			['validateTOTAL_FLOOR','擔保品總樓層不可為0', 
				function(v){
					if(v == 0){
						return false;
					}
					return true;
			}],
			['validateBUILD_AREA_ADJ','建坪需大於0', 
			function(v){
				if(v <= 0){
					return false;
					
				}
				return true;
			}],
			<%--[20250424]增-車位資料編輯檢核規則--%>
			['validatePARK_NUM','車位數量必須輸入整數 ( 0 < 車位數量 < 999)', 
				function(v){
					var PARK_NUM = v || 0;
	                var PARK_NUMA = parseInt(v || 0);
					if(PARK_NUM - PARK_NUMA !=0  || PARK_NUM <= 0 || PARK_NUM > 999 ){
						return false;
					}
					return true;
			}],
			['validatePARK_SPACE_PER','車位面積必須輸入數值(含小數點) ( 0 < 車位面積 < 99999.99)', 
				function(v){
					var PARK_SPACE_PER = parseFloat(v || 0);
					if(isNaN(PARK_SPACE_PER) || PARK_SPACE_PER <= 0 || PARK_SPACE_PER > 99999.99 ){
						return false;
					}
					return true;
			}]			
		]);
		valid = new Validation('form1', {useTitles:true, mode : 'validate'});
	}
	var actions = {
		<%-- 定義檢核 --%>	
		defineValid : function(actionType){
			valid.reset();
			valid.clear();
			<%--[20250424]增-addPSMData、updPSMData分流--%>
			if('query'==actionType){
				valid.define( 'required' , [{ id : 'APPLY_ID' , errMsg : '受理編號/原貸帳號不可為空'}] );	
			} else if('doSurvey' == actionType){
				valid.define( 'required' , [{ id : 'MODEL3_HITRATE10_M' , errMsg : '請先執行執行AVM功能'}] );
			} else if('queryLocation' == actionType) {
				valid.define( 'required' , [{ id : 'CITY_NAME' , errMsg : '縣市不可為空'} ] );
				valid.define( 'required' , [{ id : 'TOWN' , errMsg : '行政區不可為空'}] );
				valid.define( 'required' , [{ id : 'Q_ADDR' , errMsg : '地址不可為空'}] );
			}else if(['addPSMData', 'updPSMData'].include(actionType)){
				$('gridA3').select('input', 'select').each(function(ele){
					ele.id = ele.name;
					if(ele.type === 'select-one'){
						valid.define('validate-selection', [{id: ele.id}]);
					}else if(ele.readAttribute('key') === 'PARK_NUM'){
						valid.define('validatePARK_NUM', [{id: ele.id}]);
					}else if(ele.readAttribute('key') === 'PARK_SPACE_PER'){
						valid.define('validatePARK_SPACE_PER', [{id: ele.id}]);
					}
				});
			} else { <%-- 各個執行AVM的檢核 --%>
				valid.define( 'required' , [{ id : 'USE_FOR' , errMsg : '建物型態不可為空'}] );
				valid.define( 'validateUSE_FOR' , [{ id : 'USE_FOR' }] );
				valid.define( 'required' , [{ id : 'BUILD_USAGE_ADJ' , errMsg : '房屋用途不可為空'}] );
				valid.define( 'validateBUILD_USAGE_ADJ' , [{ id : 'BUILD_USAGE_ADJ' }] );
				valid.define( 'required' , [{ id : 'TRANS_FLOOR' , errMsg : '移轉層次不可為空'}] );
				valid.define( 'validate-positive-number' , [{ id : 'TRANS_FLOOR' , errMsg : '移轉層次需為有效數字'}] );
				valid.define( 'validateTRANS_FLOOR' , [{ id : 'TRANS_FLOOR'}] );
				valid.define( 'required' , [{ id : 'TOTAL_FLOOR' , errMsg : '總樓層不可為空'}] );
				valid.define( 'validate-positive-number' , [{ id : 'TOTAL_FLOOR' , errMsg : '總樓層需為有效數字'}] );
				valid.define( 'validateTOTAL_FLOOR' , [{ id : 'TOTAL_FLOOR'}] );
				valid.define( 'required' , [{ id : 'BUILD_AREA_ADJ' , errMsg : '建坪不可為空'}] );
				valid.define( 'validate-positive-number' , [{ id : 'BUILD_AREA_ADJ' , errMsg : '建坪需為有效數字'}] );
				valid.define( 'validateBUILD_AREA_ADJ' , [{ id : 'BUILD_AREA_ADJ'}] );
				valid.define( 'required' , [{ id : 'HOUSE_YEAR' , errMsg : '屋齡不可為空'}] );
				valid.define( 'validate-positive-number' , [{ id : 'HOUSE_YEAR' , errMsg : '屋齡需為有效數字'}] );
				<%-- 20221128   車位數(PARK_NUM)、車位坪數(PARK_SPACE)、車位總價(PARK_AMT)、買賣金額(TRADE_AMT)、公設比(PUB_RATE)，設計僅可輸入數字 --%>
				valid.define( 'validate-positive-number' , [{ id : 'PARK_NUM' , errMsg : '車位數需為有效數字'}] );
				valid.define( 'validate-positive-number' , [{ id : 'PARK_SPACE' , errMsg : '車位坪數需為有效數字'}] );
				valid.define( 'validate-positive-number' , [{ id : 'PARK_AMT' , errMsg : '車位總價需為有效數字'}] );
				valid.define( 'validate-positive-number' , [{ id : 'TRADE_AMT' , errMsg : '買賣金額需為有效數字'}] );
				valid.define( 'validate-positive-number' , [{ id : 'PUB_RATE' , errMsg : '公設比需為有效數字'}] );
			}
			return valid.validate();
		},
		<%-- 權限控制初始化 --%>
		initAuth : function(){
			
			var AUTH_TYPE = '${AUTH_TYPE}';
			
			if('' == AUTH_TYPE){<%-- 無權限的單位 ，按鈕失效，分頁全部隱藏 --%>
				$('tabMenuItem-tabsMenu-tab1').hide(); <%-- 基本資料輸入 --%>
				$('tabMenuItem-tabsMenu-tab2').hide(); <%-- POI計算 --%>
				$('tabMenuItem-tabsMenu-tab3').hide(); <%-- 建議案例測試 --%>
				$('tabMenuItem-tabsMenu-tab4').hide(); <%-- 模型結果 --%>
				
				$('CITY_NAME').disabled = true;
				$('TOWN').disabled = true;
				$('Q_ADDR').disabled = true;
				actions.applyID_Suggest_Disabled();
				$('btn_queryLoc').hide();
			    $('btn_AVM_A').hide();
			    $('btn_clear').hide();
			    
			    $('tabsMenu').hide();<%-- 畫面B區全部隱藏 --%>
			} else if('2' == AUTH_TYPE){<%-- 權限2僅顯示模型結果,其它隱藏 --%>
				$('tabMenuItem-tabsMenu-tab1').hide(); <%-- 基本資料輸入 --%>
				$('tabMenuItem-tabsMenu-tab2').hide(); <%-- POI計算 --%>
				$('tabMenuItem-tabsMenu-tab3').hide(); <%-- 建議案例測試 --%>
				tabs.select(3); //tab切到模型結果
				
				<%-- 隱藏模型結果的欄位 --%>
				$('tab4').select('tr[authField!=Y]').each(function(elem){
					elem.hide();
				});
				
				<%-- 查詢欄位僅查詢受編 --%>
				$('CITY_NAME').disabled = true;
				$('TOWN').disabled = true;
				$('Q_ADDR').disabled = true;
				actions.applyID_Suggest_Disabled();
				$('btn_queryLoc').hide();
				
			} else if('1-1' == AUTH_TYPE){ 
				$('tabMenuItem-tabsMenu-tab2').hide(); <%-- POI計算 --%>
				$('tabMenuItem-tabsMenu-tab3').hide(); <%-- 建議案例測試 --%>
				
				<%-- 基本資料畫面僅顯示黑字欄位 --%>
				$('tab1').select('tr[authField=Y]').each(function(elem){
					elem.hide();
				});
				
				<%-- 隱藏模型結果的欄位 --%>
				$('tab4').select('tr[authField!=Y]').each(function(elem){
					elem.hide();
				});
				
				<%-- [20221031] 問題單:20221025170652 權限為1-1時tab1的區塊高到調整為600px，為了讓畫面顯示完整 --%>
				$('tab1').setStyle({'height':'600px'});
			} else { <%-- 打個分數按鈕僅權限1-1,2 顯示 --%>
				$('btn_surveyAPI').hide();
				
				<%-- [20221031] 問題單:20221025170652 權限為1時tab4提醒事項需隱藏 --%>
				<%-- 隱藏模型結果的欄位 --%>
				$$('#tab4 div').each(function(elem){
					elem.hide();
				});
				<%-- 20221129 基本資料畫面  權限1 隱藏說明欄位 --%>
				$('tab1').select('tr[authField=Y_1]').each(function(elem){
					elem.hide();
				});
				$('tab1').setStyle({'height':'600px'});
				
				<%-- 20221201   承勳新需求 權限1-1 顯示Model3價格區間 --%>
				$('tab4').select('tr[authField=Y]').each(function(elem){
					elem.hide();
				});
			}
		},
		<%-- 依type分類取得所需參數 --%>
		getReqMap : function(type){
			
			var reqMap = {};
			
			if('query' == type){ <%-- A區查詢畫面 --%>
				reqMap = {
					APPLY_ID : $F('APPLY_ID'),
					AUTH_TYPE : $F('AUTH_TYPE')
				};
			} else if('TAB1' == type){ <%-- TAB1 - 基本資料輸入 --%>
				actions.getTableA_Tab1DataSet(reqMap);
				reqMap['ADDR'] = $F('ADDR_input');
			}  else if('TAB2' == type){ <%-- TAB2 - POI計算 --%>
				actions.getTableADataSet(reqMap);
				var poiMap = {};
				$('tab2').select('span','input').each(function(elem){
					var id = elem.id;
					poiMap[id] = actions.getValue(id);
				});
				reqMap['poiMap'] = poiMap;
				reqMap['sugList'] = grid.getAllRecords();
				var baseMap = {};
				actions.getTableA_Tab1DataSet(baseMap);
				reqMap['baseMap'] = baseMap;
				reqMap.baseMap.ADDR = $F('ADDR_input');
				var locMap = {
					ADDR : actions.getValue('ADDR_input'),
					LONGITUDE : actions.getValue('LONGITUDE'),
					LATITUDE : actions.getValue('LATITUDE')
				} 
				reqMap['locMap'] = locMap;
			} else if('TAB3' == type){ <%-- 建議案例畫面 --%>
				actions.getTableADataSet(reqMap);
				var poiMap = {};
				$('tab2').select('span','input').each(function(elem){
					var id = elem.id;
					poiMap[id] = actions.getValue(id);
				});
				reqMap['poiMap'] = poiMap;
				reqMap['sugList'] = grid.getAllRecords();
				var baseMap = {};
				actions.getTableA_Tab1DataSet(baseMap);
				reqMap['baseMap'] = baseMap;
				reqMap.baseMap.ADDR = $F('ADDR_input');
				var locMap = {
					ADDR : actions.getValue('ADDR_input'),
					LONGITUDE : actions.getValue('LONGITUDE'),
					LATITUDE : actions.getValue('LATITUDE')
				} 
				reqMap['locMap'] = locMap;
			} else if('queryLocation' == type){ <%-- 查詢座標 --%>
				reqMap = {
					CITY : $F('CITY_NAME'),
					TOWN : $('TOWN').options[$('TOWN').selectedIndex].text,
					ADDR : $F('Q_ADDR')
				};
			} else if('doSurvey' == type) {
				reqMap['FLOW_NO'] = $F('FLOW_NO');
			}
			
			return reqMap;
		},
		<%-- 取得TAB1 執行AVM所需參數 --%>
		getReqMap_tab1 : function(){
			var reqMap = {};
			$('tableA').select('span','input','select').each(function(elem){
				var id = elem.id;
				reqMap[id] = actions.getValue(id);
			});
			$('tab1').select('span','input','select').each(function(elem){
				var id = elem.id;
				reqMap[id] = actions.getValue(id);
			});
			return reqMap;
		},
		<%-- 取得元素值 --%>
		getValue : function(id){
			if(!id){ return; } <%--[20250414]--%>
			var $elem = $(id);
			var tagName = $elem.tagName.toUpperCase();
			var datatype = $elem.readAttribute('datatype');
			if(tagName === 'SPAN'){
				if('number' == datatype){
					return CSRUtil.getNumber($elem.innerHTML || '0');
				}
				return $elem.innerHTML || '';
			} else{
				if('number' == datatype){
					return CSRUtil.getNumber($elem.getValue() || '0');
				}
				return $elem.getValue() || '';
			}
		},
		<%-- 將值塞入模型結果畫面 --%>
		setQueryView : function(resp){
			
			var rtnMap = resp.rtnMap || {};
			actions.setElementValue('CASE_NAME_H','');<%-- 執行AVM功能，把 本地址關聯案名參考  清除 --%>
			<%-- A區&TAB1 --%>
			<%-- [20221031]  問題單:20221025170652 執行AVM功能時，把資料帶回畫面 --%>
		    $$('input,select,span').each(function(elem) {
				var getElemId = elem.id;
				if(!getElemId){ return; }
				if ('WELL_CONTRACT_N'===getElemId||'WELL_CONTRACT_Y'===getElemId) {
					if(rtnMap.WELL_CONTRACT=='1'){
						$('WELL_CONTRACT_Y').checked = true;
					} else if(rtnMap.WELL_CONTRACT=='0'){
						$('WELL_CONTRACT_N').checked = true;
					} else {
						$('WELL_CONTRACT_N').checked = false;
						$('WELL_CONTRACT_Y').checked = false;
					}
				} else if('CASE_NAME'===getElemId){
				    $(getElemId).value = rtnMap[getElemId] || '';
				} else if('ALL_ADDR'!=getElemId && 'Q_ADDR'!=getElemId){
					var val = rtnMap[getElemId]===0 ? '0':rtnMap[elem.id];
					actions.setElementValue(getElemId,val || '');
				}
            });
            ajaxRequest.setSynchronous(true);
            actions.getTOWN_LIST('CITY_NAME','TOWN');
            ajaxRequest.setSynchronous(false);
	    	$('TOWN').setValue(rtnMap['POST_CODE']||'');
	    	actions.setElementValue('FLOW_NO',resp.FLOW_NO || '');
			
						
			<%-- TAB2 --%>
			actions.genAllViewTab2(resp.poiMap || '',resp.hideKeysArr || '');
			
			<%-- TAB3 --%>
			grid.load(resp.sugList || []);
			
			<%-- TAB4 --%>
			<%-- 若avmMap有值,要塞入各欄位 --%>
			var avmMap = resp.avmMap || '';
			if(avmMap){
				
				$('tab4').select('span').each(function(elem){
					var value = avmMap[elem.id] === 0 ? '0' : avmMap[elem.id];
					actions.setElementValue(elem,value);
				});
				<%-- [20250414]TAB1 A2區 --%>
				actions.setA2Data(avmMap);
			}
			tabs.select(3); //tab切到模型結果
		},
		<%-- 動態產生tab2(POI計算欄位) --%>
		genAllViewTab2 : function(poiMap,hideKeysArr){
			<%-- 清空動態欄位 --%>
			$$('tr[filterfield=Y]').each(function(elem){
				elem.remove();
			});
			var poiKey_filter = []; <%-- 儲存過濾後的欄位 --%>
			var poiFieldName_filter = []; <%-- 儲存過濾後的欄位 --%>
			if(hideKeysArr){ <%-- 檢查是否要過濾欄位 --%>
				for(var i = 0;i<poiKey.length;i++){
					var key = poiKey[i];
					if(hideKeysArr.include(key)){
						continue;
					}
					poiKey_filter.push(key);
					var fieldName = poiFieldName[i];
					poiFieldName_filter.push(fieldName);
				}
			}
			
			if(poiKey_filter.length > 0){ <%-- 如果filter裡面有值就滾filter的內容 --%>
				poiKey = poiKey_filter;
				poiFieldName = poiFieldName_filter;
			}
			
			var tbodyTab2 = $('tbodyTab2');
			
			var tmptr;
			for(var i = 0;i<poiKey.length;i++){
				
				var key = poiKey[i];
				var fieldName = poiFieldName[i];
				
				if(i % 3 == 0){
					if(tmptr){ <%-- 若tr有值先insert --%>
						tbodyTab2.insert(tmptr);
					}
					tmptr = new Element('tr',{'filterField':'Y'});
				}
				actions.createAndInsertTD(tmptr,key,fieldName);
			}
			tbodyTab2.insert(tmptr); <%-- 迴圈結束後insert剩下的欄位 --%>
			
			<%-- 若poiMap有值,要塞入各欄位 --%>
			if(poiMap){
				$('tbodyTab2').select('input','span').each(function(elem){
					var value = poiMap[elem.id] === 0 ? '0' : poiMap[elem.id];
					actions.setElementValue(elem,value);
				});
			}
		},
		<%-- 產生tr內的所有欄位,td,input --%>
		createAndInsertTD : function(tr,key,fieldName){
			var td1 = new Element('td',{'class' : 'tbYellow','width' : '20%'}).update(fieldName);
			tr.insert(td1);
			var td2 = new Element('td',{'class' : 'tbYellow2','width' : '10%'});
			var input = new Element('input',{'id' : key,'name' : key,'type' : 'text','title' : fieldName,'class' : 'textBox2','style':'text-align:right'});
			td2.insert(input);
			tr.insert(td2);
		},
		<%--設定值給span或其他可以用setValue的--%>
		setElementValue : function(elem , val){
			var $elem = $(elem);
			if(!$elem){
				return;
			}	
			var tagName = $elem.tagName.toUpperCase();
			if(tagName === 'SPAN'){
				$elem.update(val || '');
			} else{
				$elem.setValue(val || '');
			}
		},	
		<%-- 取得值,如果為空設定空白 --%>
		getValueIfblank : function(val){
			return val || '';
		},	
		<%-- 建議清單初始化--%>
		suggestAll : function(){			
			Suggest.add( 
				'ALL_ADDR', 			  
		        Suggest.URL,
				'${dispatcher}/DSA3_5000/suggestAPPLY_ID',
				{						
		            ignoreCase : true,
		            startLength : 2,
		            option_key : 'ADDR',
		            remark_key : 'APPLY_ID',	
		            noCookies : true,
					'callBackFunc' : function(node,rec) { <%-- 輸入地址查詢將建議的結果放入APPLY_ID欄位 --%>
	                    $('APPLY_ID').value = rec.APPLY_ID || '';
	                    actions.setALL_ADDR_CLEAR();
					}
				}
			);
			
			<%--社區名稱搜尋，加入suggestion裡面  --%>
			Suggest.add( 
				'CASE_NAME', 			  
		        Suggest.URL,
				'${dispatcher}/DSA3_5000/suggestCaseName',
				{						
		            ignoreCase:true,
		            startLength:2,
		            option_key:"CASE_NAME",
		            remark_key:"COMMUNITY_NO",	
		            noCookies:true,
		            'callBackFunc' : function(node,rec) {
		            	<%--[20240925]回填 COMMUNITY_NO --%>
		            	actions.setElementValue('COMMUNITY_NO', '');
		            	if(rec){
		            		actions.setElementValue('COMMUNITY_NO', rec.COMMUNITY_NO);
		            	}
		            }	
				}
			);
		},
		<%-- 取得鄉鎮市區 --%>
		getTOWN_LIST : function(city_id,town_id) {
			var selectElement = $(town_id);
			selectElement.update().insert(new Element('option', {value:''}).update('請選擇'));
			var val = $F(city_id);
			if(val == ''){
				return;
			}
			//已查詢過就不用再做查詢
			if(TOWN_Map[val]&&TOWN_Map[val].length > 0){
				var opts = TOWN_Map[val];
				if(opts){
					opts.each(function(opt){
						selectElement.insert(new Element('option', {value: opt.POSTCODE}).update(opt.TOWN_NAME));
					});
				}				
			} else {
				ajaxRequest.post('getTOWN_LIST',{CITY_NAME : val},
					function(resp){
						var opts = resp.TOWN_LIST;
						TOWN_Map[val] = opts;
						if(opts){
							opts.each(function(opt){
								selectElement.insert(new Element('option', {value: opt.POSTCODE}).update(opt.TOWN_NAME));
							});
						}
					}
				);
			}
		},
		setALL_ADDR :function(){
			$('ALL_ADDR').setValue($F('CITY_NAME_1')+$('TOWN_1').options[$('TOWN_1').selectedIndex].text);
		},
		setALL_ADDR_CLEAR : function(){
			actions.setElementValue('CITY_NAME_1','');
			actions.setElementValue('TOWN_1','');
			$('ALL_ADDR').value = '';
		},
		setCASE_NAME : function(){
			$('CASE_NAME').value = actions.getValue('CASE_NAME_H');
		},
		getTableA_Tab1DataSet : function(map){
			$('tableA').select('span','input','select').each(function(elem){
				var id = elem.id;
				if('TOWN'==id){
					map[id] = $('TOWN').options[$('TOWN').selectedIndex].text;
				} else {
					map[id] = actions.getValue(id);
				}
			});
			$('tab1').select('span','input','select').each(function(elem){
				var id = elem.id;
				if ('WELL_CONTRACT_N'===id||'WELL_CONTRACT_Y'===id) {
					map['WELL_CONTRACT'] = actions.getValue(id);
				} else {
					map[id] = actions.getValue(id);
				}
			});
			<%--[20240927]取POST_CODE--%>
			if(!map['POST_CODE'] || map['POST_CODE'] == ''){
				map['POST_CODE'] = $F('TOWN');
			}
		},
		getTableADataSet : function(map){
			$('tableA').select('span','input','select').each(function(elem){
				var id = elem.id;
				if('TOWN'==id){
					map[id] = $('TOWN').options[$('TOWN').selectedIndex].text;
				} else {
					map[id] = actions.getValue(id);
				}
			});
		},
		applyID_Suggest_Disabled : function(){
			$('CITY_NAME_1').disabled = true;
			$('TOWN_1').disabled = true;
			$('ALL_ADDR').disabled = true;
		},
		func_Switch : function(){
			var survey_Flag = '${survey}';
			var applyId_Suggest_Flag = '${applyIdSuggest}';
			if('N' == survey_Flag){
				$('btn_surveyAPI').hide();<%-- 將問卷按鈕隱藏起來--%>
			}
			if('N' == applyId_Suggest_Flag){
				actions.applyID_Suggest_Disabled();<%-- 將地址反查受理編號的功能disbale--%>
			}
		},
		setA2Data: function(calMap){
			var psmList = calMap.PSM_LIST || [];
			if(psmList.length > 0){
				var TOTobj = [
					{ text: '合計' , value:{PARK_NUM: calMap.TOT_PARK_NUM, PARK_SPACE_PER: calMap.TOT_PARK_SPACE, PRICE_PS_FINAL: calMap.PSM_TOTAL_PRICE} }
				];										
				gridA2.load(psmList, TOTobj );	
			}else{
				gridA2.load([]);
			}
			gridA3.load([{}]);			
		},
		resizeTab1: function(){<%--[20250506]Tab1 resize--%>
			setTimeout(function(){
				var default_H = 600;
				var table_H = $$('#tab1 > table')[0].offsetHeight+30;
				var height = (table_H > default_H) ? table_H : default_H;
				$('tab1').style.height = height+'px';				
			}, 500);
		}
	};
	
	var buttons = {
		<%-- 執行A區AVM --%>
		doAVM_A	: function(){
			
			if(!actions.defineValid('query')){
				return;
			}
			ajaxRequest.post('doAVM_A', { reqMap : Object.toJSON(actions.getReqMap('query')) },
				function(resp) {
					actions.setQueryView(resp);
					var avmMap = resp.rtnMap;
					actions.setElementValue('ADDR_input', avmMap.ADDR);
				}
			);
		},
		<%-- 執行AVM tab1 (基本資料輸入畫面) --%>
		doAVM_TAB1 : function(){
			
			if(!actions.defineValid('TAB1')){
				return;
			}
			var parkList = gridA2.getAllRecords(['SER_NO','PARK_TYPE_PER','PARK_FLOOR_PER','PARK_SPACE_PER','PARK_NUM']);<%--[20250414]A2 區車位清單--%>
			ajaxRequest.post('doAVM_TAB1', { reqMap : Object.toJSON(actions.getReqMap('TAB1')), parkList: Object.toJSON(parkList)},
				function(resp) {
					<%-- TAB2 --%>
					actions.genAllViewTab2(resp.poiMap || '',resp.hideKeysArr || '');
					<%-- TAB3 --%>
					grid.load(resp.sugList || []);
					<%-- TAB4 --%>
					<%-- 若avmMap有值,要塞入各欄位 --%>
					var avmMap = resp.avmMap || '';
					if(avmMap){
						$('tab4').select('span').each(function(elem){
							var value = avmMap[elem.id] === 0 ? '0' : avmMap[elem.id];
							actions.setElementValue(elem,value);
						});
						<%-- [20250414]TAB1 A2區 --%>
						actions.setA2Data(avmMap);
					}
					actions.setElementValue('FLOW_NO',resp.FLOW_NO || '');
					tabs.select(3); //tab切到模型結果					
				}
			);
		},
		<%-- 執行AVM tab2 (POI計算) / 案例結果畫面 --%>
		doAVM_TYPE : function(type){ <%-- TAB2 TAB3 --%>
			
			if(!type){
				alert('請傳入執行參數');
				return;
			}
			
			if(!actions.defineValid(type)){
				return;
			}
			var parkList = gridA2.getAllRecords(['SER_NO','PARK_TYPE_PER','PARK_FLOOR_PER','PARK_SPACE_PER','PARK_NUM']);;<%--[20250414]A2 區車位清單--%>			
			ajaxRequest.post('doAVM_'+type, { reqMap : Object.toJSON(actions.getReqMap(type)), parkList: Object.toJSON(parkList)},
				function(resp) {
					var avmMap = resp.avmMap || '';
					if(avmMap){
						$('tab4').select('span').each(function(elem){
							var value = avmMap[elem.id] === 0 ? '0' : avmMap[elem.id];
							actions.setElementValue(elem,value);
						});
						<%-- [20250414]TAB1 A2區 --%>
						actions.setA2Data(avmMap);
					}
					tabs.select(3); //tab切到模型結果
				}
			);
		},
		<%-- 座標查詢 --%>
		doQueryLoc : function(){
			
			if(!actions.defineValid('queryLocation')){
				return;
			}
			
			ajaxRequest.post('queryLocation', { reqMap : Object.toJSON(actions.getReqMap('queryLocation')) },
				function(resp) {
					actions.setElementValue('LONGITUDE',resp.LONGITUDE);
					actions.setElementValue('LATITUDE',resp.LATITUDE);
					actions.setElementValue('ADDR',resp.ADDR);
					actions.setElementValue('ADDR_input',resp.ADDR);
					var commMap = resp.commMap || [];
					<%--[20240925]改用commMap.CASE_NAME，增COMMUNITY_NO、POST_CODE--%>
					actions.setElementValue('CASE_NAME_H', commMap.CASE_NAME);
					actions.setElementValue('COMMUNITY_NO', commMap.COMMUNITY_NO);
					actions.setElementValue('POST_CODE', commMap.POST_CODE);
					$('CASE_NAME_H').simulate('click');
				},
				function(resp) {
					actions.setElementValue('LONGITUDE','');
					actions.setElementValue('LATITUDE','');
					actions.setElementValue('ADDR','');
					actions.setElementValue('CASE_NAME_H', '');
					actions.setElementValue('COMMUNITY_NO', '');
					actions.setElementValue('POST_CODE', '');
				}
			);
			actions.setA2Data({});<%-- [20250506]A2區 清空 --%>
			tabs.select(0);//tab切換到基本資料輸入			
			actions.resizeTab1();<%--[20250506]重新resize--%>
		},
		<%-- 清除 --%>
		doClear : function(){
			actions.setElementValue('CITY_NAME','');
			actions.setElementValue('TOWN','');
			actions.setElementValue('CITY_NAME_1','');
			actions.setElementValue('TOWN_1','');
			actions.setElementValue('Q_ADDR','');
			actions.setElementValue('CASE_NAME_H','');
			actions.setElementValue('FLOW_NO','');
			actions.setElementValue('APPLY_ID','');
			actions.setElementValue('LONGITUDE','');
			actions.setElementValue('LATITUDE','');
			actions.setElementValue('SLOGAN_MEMO','');<%--[20250414]受理編號鑑價紀錄--%>
			$('ALL_ADDR').value = '';
		},
		<%-- 打個分數 --%>
		doSurveyAPI : function(){
			
			if(!actions.defineValid('doSurvey')){
				return;
			}
			
			ajaxRequest.post('doSurveyAPI', { reqMap : Object.toJSON(actions.getReqMap('doSurvey')) },
				function(resp) {
					var quest_url = resp.rtnMap.quest_url || '';
					if(quest_url){
						window.open(quest_url);
					}
				}
			);
		}
	};
	
	return {
		initApp : function() {
			PageUI.createPageWithAllBodySubElement( 'DSA35000', '鑑價作業', '自動估價模型作業');
			<cathay:LocaleDisplay 
			dateFields='BUILD_DATE TRADE_DATE' 
			numberFields='TRANS_FLOOR TOTAL_FLOOR BUILD_AREA_ADJ HOUSE_YEAR PARK_NUM PARK_SPACE PARK_AMT TRADE_AMT PUB_RATE'
			sysCode='DS' var='localeDisplay' />
			
			<%-- 頁籤設定 --%>
			tabs = new Tabs({
				id: 'tabsMenu',
				tabs: [
					{'id': 'tab1', 'title': '基本資料輸入'},
					{'id': 'tab2', 'title': 'POI計算'},
					{'id': 'tab3', 'title': '建議案例結果'},
					{'id': 'tab4', 'title': '模型結果'},
				],
				onClickAction: function(id) {},
				afterSwitch: function(info){
					if(info.to == 'tab1'){
						<%--[20250506]車位數量多筆，tab高度會不夠，重新resize--%>
						actions.resizeTab1();
					}
				},
			});
			
			<%-- tableUI 初始化 --%>
			<%-- [20241001]  難字調整 --%>
			grid = new TableUI({
				table : $('grid') , allSortable: true,
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column : [
					{ header:'地址' , key:'ADDR', style:"font-family:'EUDC'",
						render : function(rec,val) {
							var v1 = rec.ADDR ? rec.ADDR : '';
							var v2 = rec.COMMUNITY_NAME ? "(" + rec.COMMUNITY_NAME + ")" : '';
							return v1 + v2;
	                    }
					},
					{ header:'交易年月' , key:'TRADE_YM' },
					{ header:'屋齡' , key:'HOUSE_YEAR' },
					{ header:'樓層' , key:'TRANS_FLOOR',
						render : function(rec,val,sn) {
	                        var v1 = rec.TRANS_FLOOR ? rec.TRANS_FLOOR : '';
							var v2 = rec.TOTAL_FLOOR ? rec.TOTAL_FLOOR : '';
							return v1 + "/" + v2;
	                    }
					},
					{ header:'總價' , key:'TOTAL_PRICE',
						render : function(record,val){
							val = val ? CSRUtil.$fmt(val, "#,##0") : "0";
							return val;
						}
					},
					{ header:'建坪' , key:'BUILD_AREA_ADJ' },
					{ header:'建坪單價' , key:'BUILD_U_PRICE_ADJ' , <%-- 輸入欄位 --%>
						input: { type : 'NUMBER' } 	
					}, 
					{ header:'車位坪' , key:'PARK_AREA'  },
					{ header:'車位價格' , key:'PARK_PRICE' },
				]
			});
			<%--[20250414]車位清單與合計--%>
			gridA2 = new TableUI({
				table : $('gridA2'),
				title: '車位資料清單',
				pageSize: 3,<%--[20250507]一頁3筆--%>
    			column : [
					{ header:'序號' , key:'SER_NO', 
						render : function(rec, val) {
							var link = new Element('a', { href: 'javascript:void(0)' }).update(val);
							link.observe('click', function(){
								gridA3.load([rec]);
							});							
							return link;
	                    }
					},
					{ header:'車位樓層' , key:'PARK_FLOOR_NAME',
						render : function(rec,val) {
							if(!val && rec.PARK_FLOOR_PER){
								return PARK_FLOOR_Map[rec.PARK_FLOOR_PER];
							}
							return val;
	                    }
					},
					{ header:'車位型態' , key:'PARK_TYPE_NAME',
						render : function(rec,val) {
							if(!val && rec.PARK_TYPE_PER){
								return PARK_TYPE_Map[rec.PARK_TYPE_PER];
							}
							return val;
	                    }
					},
					{ header:'車位個數(個)' , key:'PARK_NUM', sortRule: 'number'},
					{ header:'車位面積(坪/個)' , key:'PARK_SPACE_PER', sortRule: 'number'},
					{ header:'模型車位價格(萬/個)' , key:'PRICE_PS_FINAL', sortRule: 'number'},
					{ header:'編輯' , key:'',
						input:{
							type:'button',
							text:'刪除',
							action : function( node , dataObj , textDiv, orgData, isOnChange ){
								var parkList = gridA2.getAllRecords(['SER_NO','PARK_TYPE_PER','PARK_FLOOR_PER','PARK_SPACE_PER','PARK_NUM','PRICE_PS_FINAL']);
								ajaxRequest.post('delPSMData', { reqMap : Object.toJSON(dataObj[0]), parkList: Object.toJSON(parkList)},
									function(resp) {
										var calMap = resp.calMap || {};	
										actions.setA2Data(calMap);
									}
								);
							}
						}
					}
				]
			});
			gridA3 = new TableUI({
				table : $('gridA3'), pageSize:0,
				title: '車位資料編輯',
				column : [
					{ header:'序號' , key:'SER_NO' },
					{ header:'車位樓層' , key:'PARK_FLOOR_PER',
						input:{
							type:'select',
							opts_before: {"":"請選擇"},
							opts: PARK_FLOOR_Map
						}
					},
					{ header:'車位型態' , key:'PARK_TYPE_PER',
						input:{
							type:'select',
							opts_before: {"":"請選擇"},
							opts: PARK_TYPE_Map
						}
					},
					{ header:'車位個數(個)' , key:'PARK_NUM', sortRule: 'number',
						input:{
							type:'NUMBER', maxlength:3
						}
					},
					{ header:'車位面積(坪/個)' , key:'PARK_SPACE_PER', sortRule: 'number',
						input:{
							type:'NUMBER', maxlength:9, pattern:'#,###.####'
						}
					},
					{ header:'編輯' , key:'',
						render : function(rec,val) {							
							var btnI = new Element('button', { type:'button', className: 'button'}).update('新增');
							btnI.observe('click', function(){
								actFunc('addPSMData');
							});	
							var btnU = new Element('button', { type:'button', className: 'button'}).update('修正');							
							btnU.observe('click',function(){
								actFunc('updPSMData');
							});	
							var div = new Element('div');
							div.insert(btnI).insert(btnU);
							var actFunc = function(act){
								if(!actions.defineValid(act)){
									return;
								}
								<%--[20250424]改用defineValid檢核--%>								
								var parkList = gridA2.getAllRecords(['SER_NO','PARK_TYPE_PER','PARK_SPACE_PER','PARK_FLOOR_PER','PARK_NUM','PRICE_PS_FINAL']);
								ajaxRequest.post(act, { 
									reqMap : Object.toJSON(rec), parkList: Object.toJSON(parkList)
								}, function(resp){
									var calMap = resp.calMap || {};	
									actions.setA2Data(calMap);
									actions.resizeTab1();<%--[20250506]重新resize--%>
								});
							};
							
							return div;
	                    }
					}
				]
			});
			gridA3.load([{}]);
			
			$('CITY_NAME').observe('change', function(){actions.getTOWN_LIST('CITY_NAME','TOWN')}); <%--「縣市別」下拉選單連動 「鄉鎮區」下拉選單 --%>
			$('CITY_NAME_1').observe('change', function(){actions.getTOWN_LIST('CITY_NAME_1','TOWN_1')});
			$('btn_AVM_A').observe('click', buttons.doAVM_A);
			$('btn_AVM_TAB1').observe('click', buttons.doAVM_TAB1);
			$('btn_AVM_TAB2').observe('click', function(){buttons.doAVM_TYPE('TAB2')});
			$('btn_AVM_TAB3').observe('click', function(){buttons.doAVM_TYPE('TAB3')});
			$('btn_queryLoc').observe('click', buttons.doQueryLoc);
			$('btn_clear').observe('click', buttons.doClear);
			$('btn_surveyAPI').observe('click', buttons.doSurveyAPI);
			$('TOWN_1').observe('change', actions.setALL_ADDR);
			$('CASE_NAME_H').observe('click', actions.setCASE_NAME);
			actions.suggestAll(); <%-- 建議選單初始化 --%>
			
			initValidation();
			displayMessage();
			autoFormatToNumber();
			
			actions.genAllViewTab2(null,null);
			actions.initAuth(); <%-- 權限控制初始化 --%>
			actions.func_Switch(); <%-- 功能控制初始化 --%>
		}
	}
}

</script>
</head>
<body style='PADDING: 0px; MARGIN: 0px;'>
	<form name='form1' id='form1'>
		<table id='tableA' width='100%' class='tbBox2'>
			<tr>
				<td class='tbYellow' width='10%' rowspan="2">地址</td>
				<td class='tbYellow2' width='8%' >1. 受理編號查詢 : </td>
				<td class='tbYellow2' >
					<select name='CITY_NAME_1' id='CITY_NAME_1' title='縣市別_反查' fieldName='縣市別'>
                        <option value=''>請選擇</option>
                        <c:forEach var='map' items='${CITY_LIST}'>
                            <option value='${map.CITY_NAME}'>${map.CITY_NAME}</option>
                        </c:forEach>
                    </select>
					<select name='TOWN_1' id='TOWN_1' title='行政區反查' fieldName='行政區'>
                        <option value=''>請選擇</option>
                    </select>
                    <%-- [20241001]  難字調整 --%>
					<input id='ALL_ADDR' name='ALL_ADDR' type='text' title='地址欄' class='textBox2' size='70' maxlength='60' alt="ch" />
				</td>
				<td class='tbYellow2' rowspan="6" width='30%' align='center'>
					<button id='btn_queryLoc' name='btn_queryLoc' type='button' class='button'>座標查詢</button>
					<button id='btn_AVM_A' name='btn_AVM_A' type='button' class='button'>執行AVM</button>
					<button id='btn_clear' name='btn_clear' type='button' class='button'>清除</button>
					<%-- 放隱藏欄位 --%>
					<input id='FLOW_NO' name='FLOW_NO' type='hidden' />
					<input id='AUTH_TYPE' name='AUTH_TYPE' type='hidden' value='${AUTH_TYPE}' />
					<%-- 20221129 221031006781 新增隱藏欄位，避免有同擔前件的資料與各頁簽AVM輸出的差異 --%>
					<input id='PER_PRICE' name='PER_PRICE' type='hidden' />
					<input id='BROKER_NAME' name='BROKER_NAME' type='hidden' />
					<input id='POST_CODE' name='POST_CODE' type='hidden' />
					<input id='PARK_AREA' name='PARK_AREA' type='hidden' />
				</td>
			</tr>
			<tr>
			    <td class='tbYellow2' >2. 座標查詢 : </td>
				<td class='tbYellow2' >
					<select name='CITY_NAME' id='CITY_NAME' title='縣市別' fieldName='縣市別'>
                        <option value=''>請選擇</option>
                        <c:forEach var='map' items='${CITY_LIST}'>
                            <option value='${map.CITY_NAME}'>${map.CITY_NAME}</option>
                        </c:forEach>
                    </select>
					<select name='TOWN' id='TOWN' title='行政區' fieldName='行政區'>
                        <option value=''>請選擇</option>
                    </select>
                    <%-- [20241001]  難字調整 --%>
                    <input id='Q_ADDR' name='Q_ADDR' type='text' title='地址' class='textBox2' size='70' maxlength='60' alt="ch" />
				</td>
			</tr>
			<tr>
				<td class='tbYellow' width='10%'>受理編號/原貸帳號</td>
				<td class='tbYellow2' colspan='2'> <%-- APPLY_ID/REFER_ID --%>
					<input id='APPLY_ID' name='APPLY_ID' type='text' title='受理編號/原貸帳號' class='textBox2' />
				</td>
			</tr>
			<tr><%-- [20250414] 增加受理編號鑑價紀錄--%>
				<td class='tbYellow' width='10%'>受理編號鑑價紀錄</td>
				<td class='tbYellow2' colspan='2'> 
					<span id='SLOGAN_MEMO'></span>
				</td>
			</tr>
			<tr>
				<td class='tbYellow' rowspan='2' width='10%'>座標查詢結果</td>
				<td class='tbYellow2' colspan='2'>經度:<span id='LONGITUDE'></span></td>
			</tr>
			<tr><td class='tbYellow2' colspan='2'>緯度:<span id='LATITUDE'></span></td></tr>
		</table>
		<div id='tabsMenu'></div> <%-- 頁籤 --%>
		<div id='tab1' class='tbBox2'> <%--<div id="tab1">  基本資料輸入 --%>
			<table width='100%' class='tbBox2'>
					<tr>
						<td class='tbYellow' width='10%'>地址</td>
						<td class='tbYellow2'>
							<%-- [20241001]  難字調整 --%>
							<span id='ADDR' style="font-family:'EUDC'"></span>
							<input type='hidden' id='ADDR_input' name='ADDR_input' value='' />
						</td>
						<td class='tbYellow2' colspan='2'>
							<button id='btn_AVM_TAB1' name='btn_AVM_TAB1' type='button' class='button'>執行AVM</button>
						</td>
					</tr>
					<tr>
						<td class='tbYellow' width='10%'><font color="red">*</font>建築型態</td> <%-- 必填 --%>
						<td class='tbYellow2'>
							<select id='USE_FOR' key='USE_FOR'>
								<option value=''>請選擇</option>
								<option value='1'>公寓</option>
								<option value='3'>住宅大樓</option>
								<option value='5'>住辦大樓</option>
								<option value='F'>樓中樓</option>
								<option value='G'>套房</option>
							</select>
						</td>
						<td class='tbYellow' width='10%'><font color="red">*</font>房屋用途</td> <%-- 必填 --%>
						<td class='tbYellow2'>
							<select id='BUILD_USAGE_ADJ' key='BUILD_USAGE_ADJ'>
								<option value=''>請選擇</option>
								<option value='1'>住家用</option>
								<option value='9'>住商用</option>
								<option value='5'>商業用</option>
								<option value='4'>工業用</option>
								<option value='6'>國民住宅</option>
							</select>
						</td>
					</tr>
					<tr>
						<td class='tbYellow' width='10%'><font color="red">*</font>移轉層次</td> <%-- 必填 輸入欄位，僅可輸入數字 --%>
						<td class='tbYellow2'>
							<input id='TRANS_FLOOR' name='TRANS_FLOOR' type='text' title='移轉層次' class='textBox2' datatype='number' pattern='#,###.00' />
						</td>
						<td class='tbYellow' width='10%'><font color="red">*</font>總樓層</td> <%-- 必填 輸入欄位，僅可輸入數字 --%>
						<td class='tbYellow2'>
							<input id='TOTAL_FLOOR' name='TOTAL_FLOOR' type='text' title='總樓層' class='textBox2' datatype='number' pattern='#,###.00' />
						</td>
					</tr>
					<tr>
						<td class='tbYellow' width='10%'><font color="red">*</font>建坪(坪)(不含車位)</td>
						<td class='tbYellow2'>
							<input id='BUILD_AREA_ADJ' name='BUILD_AREA_ADJ' type='text' title='建坪' class='textBox2' datatype='number' pattern='#,###.00' /> <%-- 必填 輸入欄位，僅可輸入數字 --%>
						</td>
						<td class='tbYellow' width='10%'><font color="red">*</font>屋齡</td>
						<td class='tbYellow2'>
							<input id='HOUSE_YEAR' name='HOUSE_YEAR' type='text' title='屋齡' class='textBox2' datatype='number' pattern='#,###.00' /> <%-- 必填 輸入欄位，僅可輸入數字 --%>
						</td>
					</tr>
					<tr>
						<td class='tbYellow' width='10%'>案名</td>
						<td class='tbYellow2'>
							<input id='CASE_NAME' name='CASE_NAME' type='text' title='案名' class='textBox2' /> <%-- 輸入欄位，可透過串接社區編號API自動帶入。 --%>
							 ※社區案名參考(點選輸入) : <span id='CASE_NAME_H'></span>
						</td>
						<td class='tbYellow' width='10%'>社區編號</td>
						<td class='tbYellow2'>
							<input id='COMMUNITY_NO' name='COMMUNITY_NO' type='text' title='社區編號' class='textBox2' disabled/> <%-- [20240925]增 --%>
							<input id='POST_CODE' name='POST_CODE' type='hidden' title='郵遞區號' class='textBox2'/>
						</td>						
					</tr>
					<tr authField='Y'>
						<td class='tbYellow' width='10%'>建築完成日</td>
						<td class='tbYellow2'>
							<input id='BUILD_DATE' name='BUILD_DATE' type='text' title='建築完成日' class='textBox2' /> <%-- 跳出日期選單(僅可輸入西元年月日) ，預設空值 --%>
						</td>
						<td class='tbYellow' width='10%'>車位型態</td>
						<td class='tbYellow2'>
							<select id='PARK' key='PARK'>
								<option value='1'>無</option>
								<option value='2'>一樓平面</option>
								<option value='3'>一樓機械</option>
								<option value='5'>坡/平</option>
								<option value='6'>坡/機</option>
								<option value='7'>機/平</option>
								<option value='8'>機/機</option>
								<option value='9'>倉儲式</option>
							</select>
						</td>
					</tr>
					<tr authField='Y'>
						<td class='tbYellow' width='10%'>車位數</td>
						<td class='tbYellow2'>
							<input id='PARK_NUM' name='PARK_NUM' type='text' title='車位數' class='textBox2' datatype='number' pattern='#,###.0' /> <%-- 輸入欄位，僅可輸入數字 --%>
						</td>
						<td class='tbYellow' width='10%'>車位總坪數(坪)</td>
						<td class='tbYellow2'>
							<input id='PARK_SPACE' name='PARK_SPACE' type='text' title='車位坪數' class='textBox2' datatype='number' pattern='#,###.00' /> <%-- 輸入欄位，僅可輸入數字 --%>
						</td>
					</tr>
					<tr authField='Y'>
						<td class='tbYellow' width='10%'>車位總價(萬)</td>
						<td class='tbYellow2'>
							<input id='PARK_AMT' name='PARK_AMT' type='text' title='車位總價' class='textBox2' datatype='number' pattern='#,###.00' /> <%--  輸入欄位，僅可輸入數字 --%>
						</td>
						<td class='tbYellow' width='10%'>買賣金額(萬)</td>
						<td class='tbYellow2'>
							<input id='TRADE_AMT' name='TRADE_AMT' type='text' title='買賣金額' class='textBox2' datatype='number' pattern='#,###.00' /> <%--  輸入欄位，僅可輸入數字 --%>
						</td>
					</tr>
					<tr authField='Y'>
						<td class='tbYellow' width='10%'>買賣日期</td>
						<td class='tbYellow2'>
							<input id='TRADE_DATE' name='TRADE_DATE' type='text' title='買賣日期' class='textBox2' /> <%-- 跳出日期選單(僅可輸入西元年月日) ，預設空值 --%>
						</td>
						<td class='tbYellow' width='15%'>是否為完整∕正確的買賣契約</td>
						<td class='tbYellow2'>
				            <input id = 'WELL_CONTRACT_Y' name='WELL_CONTRACT' type="radio" value ='1' title='是否為完整∕正確的買賣契約' class='textBox2' >是
							<input id = 'WELL_CONTRACT_N' name='WELL_CONTRACT'  type="radio" value ='0' title='是否為完整∕正確的買賣契約' class='textBox2' >否
						</td>
					</tr>
					<tr authField='Y'>
						<td class='tbYellow' width='10%'>公設比</td>
						<td class='tbYellow2' colspan='3'>
							<input id='PUB_RATE' name='PUB_RATE' type='text' title='公設比' class='textBox2' datatype='number' pattern='#,###.00' /> <%--  輸入欄位，僅可輸入數字 --%>
						</td>
					</tr>
					<tr>
						<td class='tbYellow2' colspan='4' style='text-align:center'><font color="red">*</font>為必填欄位</td>
					</tr>
					<tr><%--[20250414]+A2、A3區--%>
						<td class='tbYellow2' colspan='4'>
							<table id='gridA2' class="grid"></table>
						</td>
					</tr>
					<tr>
						<td class='tbYellow2' colspan='4'>
							<table id='gridA3' class="grid"></table>
						</td>
					</tr>
					<tr authField='Y_1'>
						<td class="tbYellow" colspan="4">※已知受理編號/原貸帳號時<br>
						請直接輸入受理編號/原貸帳號於受理編號/原貸帳號欄位，點選上方「執行AVM」按鈕<br>
						※未知受理編號/原貸帳號時<br>
						1.請於受理編號查詢欄位輸入部分或完整地址查詢既有受理編號，點選建議清單將受理編號帶入受理編號欄位，點選上方「執行AVM」按鈕<br>
						2.查無既有受理編號，請清除受理編號查詢欄位內地址，改於座標查詢欄位輸入完整地址，點選上方「座標查詢」按鈕<br>
						3.座標查詢完畢，請於基本資料輸入欄位輸入擔保品建築型態、房屋用途、移轉層次、總樓層、建坪、屋齡、案名(如有)，點選下方「執行AVM」按鈕
						</td>
					</tr>
				</table>
		</div>
		<div id='tab2' > <%-- POI計算  --%>
			<table width='100%' class='tbBox2'>
				<tbody id='tbodyTab2'>
				<tr>
					<td class='tbYellow' width='10%'>POI版本</td>
					<td class='tbYellow2'>
						<span id='POI_VER' key='POI_VER'></span>	
					</td>
					<td class='tbYellow2' colspan='4'>
						<button id='btn_AVM_TAB2' name='btn_AVM_TAB2' type='button' class='button'>執行AVM</button>
					</td>
				</tr>
				</tbody>
			</table>
		</div>
		<div id='tab3'> <%-- 建議案例測試 --%>
			<div align='center'><table id="grid" class="grid"></table></div>
			<div align='center' class='tbYellow2'>
				<button id='btn_AVM_TAB3' name='btn_AVM_TAB3' type='button' class='button'>執行AVM</button>
			</div>
		</div>
		<div id='tab4' class='tbBox2'> <%-- 模型結果 --%>
			<table width='100%' class='tbBox2'>
				<tr>
					<td class='tbYellow' width='20%'>房屋鑑價模型版本</td>
					<td class='tbYellow2' colspan='3'>
						<span id='MODEL_VER'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>實價模型1預測價格(萬/坪)</td>
					<td class='tbYellow2' width='15%'>
						<span id='PRICE_REAL_MODEL1'></span>
					</td>
					<td class='tbYellow' width='20%'>鑑價模型1預測價格(萬/坪)</td>
					<td class='tbYellow2' width='15%'>
						<span id='PRICE_EVAL_MODEL1'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>實價模型2預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_REAL_MODEL2'></span>
					</td>
					<td class='tbYellow' width='10%'>鑑價模型2預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_EVAL_MODEL2'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>實價模型3預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_REAL_MODEL3'></span>
					</td>
					<td class='tbYellow' width='10%'>鑑價模型3預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_EVAL_MODEL3'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>實價模型4預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_REAL_MODEL4'></span>
					</td>
					<td class='tbYellow' width='10%'>鑑價模型4預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_EVAL_MODEL4'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>實價模型5預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_REAL_MODEL5'></span>
					</td>
					<td class='tbYellow' width='10%'>鑑價模型5預測價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_EVAL_MODEL5'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>實價模型平均價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_REAL_FINAL'></span>
					</td>
					<td class='tbYellow' width='10%'>鑑價模型平均價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='PRICE_EVAL_FINAL'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>社區參考價格下限(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='COMM_MIN_PRICE'></span>
					</td>
					<td class='tbYellow' width='10%'>擔保品行情參考價格下限(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='APPR_MIN_PRICE'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>社區參考價格上限(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='COMM_MAX_PRICE'></span>
					</td>
					<td class='tbYellow' width='10%'>擔保品行情參考價格上限(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='APPR_MAX_PRICE'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>model3價格下限(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='MODEL3_MIN_PRICE'></span>
					</td>
					<td class='tbYellow' width='10%'>價格參考種類</td>
					<td class='tbYellow2'>
						<span id='PRICE_REFER_TYPE'></span>
					</td>
				</tr>
				<tr>
					<td class='tbYellow' width='10%'>model3價格上限(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='MODEL3_MAX_PRICE'></span>
					</td>
					<td class='tbYellow' width='10%'>參考案件清單</td>
					<td class='tbYellow2'>
						<span id='REFER_CASE_LIST'></span>
					</td>
				</tr>

				<tr> <%--[20250414] 權限1-1、2顯示 --%>
					<td class='tbYellow' width='10%'>Model3平均價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='MODEL3_AVG_PRICE'></span>
					</td>
					<td class='tbYellow' width='10%'>模型車位總價(萬)</td>
					<td class='tbYellow2' >
						<span id='PSM_TOTAL_PRICE'></span>
					</td>					
				</tr>	
				<tr>
					<td class='tbYellow' width='10%'>建坪單價(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='MODEL3_AVG_PRICE'></span>
					</td>
                    <td class='tbYellow' width='10%'>模型評估總價(萬)</td>					
					<td class='tbYellow2'>
						<span id='MODEL3_TOTAL_PRICE'></span>
					</td>					
				</tr>							
				<tr authField='Y'>
					<td class='tbYellow' width='10%'>Model3價格區間下限</td>
					<td class='tbYellow2' >
						<span id='MODEL3_HITRATE10_M'></span>
					</td>
					<td class='tbYellow' width='10%'>Model3價格區間上限</td>
					<td class='tbYellow2'>
						<span id='MODEL3_HITRATE10_H'></span>
					</td>
				</tr>
				<tr authField='Y'> <%--[20250414] 權限1-1、2顯示 --%>
					<td class='tbYellow' width='10%'>Model3平均價格(萬/坪)</td>
					<td class='tbYellow2'>
						<span id='MODEL3_AVG_PRICE'></span>
					</td>
					<td class='tbYellow' width='10%'>模型車位總價(萬)</td>
					<td class='tbYellow2' >
						<span id='PSM_TOTAL_PRICE'></span>
					</td>					
				</tr>		
				<tr authField='Y'><%--[20250414]新增欄位 --%>
					<td class='tbYellow' width='10%'></td>
					<td class='tbYellow2'></span>
					</td>
					<td class='tbYellow' width='10%'>模型評估總價(萬)</td>
					<td class='tbYellow2'>
						<span id='MODEL3_TOTAL_PRICE'></span>
					</td>
				</tr>						

				<tr authField='Y'> <%-- 權限1-1、2顯示 --%>
					<td class='tbYellow2' colspan='4' style='text-align:center'>
						<button id='btn_surveyAPI' name='btn_surveyAPI' type='button' class='button'>打個分數</button>
					</td>
				</tr>
				<tr authField='Y'>
					<td class='tbYellow2' colspan='4'>
						<div style='color:red'>使用提醒：<br>
						 	 1.自動估價模型並非為確切鑑價結果且有限定鑑價範圍，模型結果僅供參考，實際鑑估價格仍以報告為準。<br>
						 	 2.特殊性質產品(如國宅、工商業使用、風水景觀等)易受個案影響，價格落差大。<br>
						 	 3. 模型評估價總價(萬)為建坪(坪)(不含車位) X Model3平均價格(萬/坪) + 模型車位總價(萬)
						</div>
					</td>
				</tr>
			</table>
		</div>
	</form>
</body>
</html>