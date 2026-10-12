<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30900.jsp
作者：謝雅筑
功能：擔保品行情查詢
完成：2012/03/22

[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>

<style type="text/css">
@font-face {
font-family: 'EUDC';
  src: url("/DSWeb/hanlinks/eudc.woff") format("woff"),
       url("/DSWeb/hanlinks/eudc.ttf") format("truetype");
 font-weight: normal;
 font-style: normal
}
</style>

<script type="text/javascript">

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA30900().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30900(){
	
	var valid1;
	var valid2;
	var viewMap;
	var grid;
	var view_type;//儲存目前使用的畫面種類
	var AMT_Formate = '#,###.####';
	var showApplyId = '${showApplyId}';
	var TOWN_Map = {};//儲存已查詢的鄉鎮
	var gridColumn = [
						{header: "編號",key: "APPLY_ID" ,attrs:{rowSpan:2, width:'10%'} ,
		              		render:function(record,value){
		              			if(value){
		              				value = new Element('a', {href :'#'}).update(value).observe('click',function(){actions.doWindowOpen(record.QUERY_TYPE,record.APPLY_ID)});
		              			}	          
		              			return value;
		              		}
            			},
						{header: "地址",key: "ADDRESS" , attrs:{rowSpan:2, align:'left'}, styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
		              		render:function(record,value){
		              			if(value){
		              				if(record.CONTRACT_AREA == '1' || parseInt(record.RESTRICT_AREA,10) > 1){
		              					value = '<FONT color="green">$$ </FONT>' + value;
		              				}		  
		              				if(parseInt(record.CNT,10) > 1){
		              					value = '<FONT color="blue">@@ </FONT>' + value;
		              				}	
		              				if(record.IS_ADD == '1'){
		              					value = '<FONT color="red">** </FONT>' + value;
		              				}            				              				
		              			}	          
		              			return value;
		              		}
            			},
						{header: "地坪" ,key: "LAND_MEASURE" },
						{header: "車位型態" ,key: "PARK_NM" ,
		               		render:function(record,value){
		               			if(record.USE_FOR_NM == undefined){
		               				value = '無車位型態';
		               			}
		               		 	return  value;
		               		}
		            	},
						{header: "單價" ,key: "BOSS_PER_PRICEA" ,
		               		render:function(record,value){
		               			if(record.BOSS_PER_PRICEA == undefined){
		               				value = '無單價';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value ;
		               		}
		            	},
						{header: "總價" ,key: "BOSS_TOTAL_PRICEA" ,
		               		render:function(record,value){
		               			if(record.QUERY_TYPE == '3' && record.BOSS_TOTAL_PRICEA == null){
		               				value = '無總價';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value;
		               		}
		            	},
						{header: "總樓層" ,key: "FLOOR" ,
		               		render:function(record,value){
		               			if(record.FLOOR == undefined){
		               				value = '無總樓層';
		               			}
		               		 	return  value;
		               		}
		            	},
						{header: "建築日" ,key: "FINISH_DATE" ,
		               		render:function(record,value){
		               		
		               			if(record.FINISH_DATE == undefined){
		               				value = '無建築日';
		               			}else{
		               				value = Date.toROC(value);
		               			}
		               		 	return value ;
		               		}
		            	},
		            	{header: "類別" ,key: "USE_FOR_NM" ,
		               		render:function(record,value){
		               			if(record.USE_FOR_NM == undefined){
		               				value = '無類別';
		               			}
		               		 	return  value;
		               		}
		            	},
						{header: "買賣日" ,key: "TRADE_DATE" ,
		               		render:function(record,value){
		               		
		               			if(record.TRADE_DATE == undefined){
		               				value = '無買賣日';
		               			}else{
		               				value = Date.toROC(value);
		               			}
		               		 	return value ;
		               		}
		            	},
						{header: "屋齡" ,key: "BUILD_AGE" ,
		               		render:function(record,value){
		               			if(record.BUILD_AGE == undefined){
		               				value = '無屋齡';
		               			}
		               		 	return  value;
		               		}
		            	},
						
						{header: "建坪" ,key: "BUILD_MEASURE" },
						{header: "車位價" ,key: "BOSS_PARK_PRICEA" ,
		               		render:function(record,value){
		               			if(record.BOSS_PARK_PRICEA == undefined){
		               				value = '無車位價';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value ;
		               		}
		            	},
						{header: "地價" ,key: "BOSS_LAND_PRICEA" ,
		               		render:function(record,value){
		               			if(record.BOSS_LAND_PRICEA == undefined){
		               				value = '無地價';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value ;
		               		}
		            	},
						{header: "均價" ,key: "AVG_PRICE" ,
		               		render:function(record,value){
		               			if(record.AVG_PRICE == undefined){
		               				value = '無均價';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value ;
		               		}
		            	},
		            	{header: "樓別" ,key: "BUILD_TYPE" ,
		               		render:function(record,value){
		               			if(record.BUILD_TYPE == undefined){
		               				value = '無樓別';
		               			}
		               		 	return  value;
		               		}
		            	},
						{header: "鑑估日" ,key: "APPR_DATE" ,
		               		render:function(record,value){
		               		 	return Date.toROC(value);
		               		}
		            	},
		            	{header: "案名" ,key: "CASE_NAME" ,
		               		render:function(record,value){
		               			if(record.CASE_NAME == undefined){
		               				value = '無案名';
		               			}
		               		 	return  value;
		               		}
		            	},
						{header: "買賣價" ,key: "TRADE_AMT" ,
		               		render:function(record,value){
		               			if(record.TRADE_AMT == undefined){
		               				value = '無買賣價';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value ;
		               		}
		            	},
		            	{header: "租金" ,key: "RENT_PRICE" ,
		               		render:function(record,value){
		               			if(record.RENT_PRICE == undefined){
		               				value = '無租金';
		               			}else{
		               				value = CSRUtil.$fmt(value ,AMT_Formate) ;
		               			}
		               		 	return value ;
		               		}
		            	}
					];
					
	var actions = {
		
		//初始查詢
		doPromptQuery:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			ajaxPost('promptQuery',{APPLY_ID:$F('APPLY_ID'), showApplyId:showApplyId},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
				},
				function(){
					grid.load([]);
				}
			);			
		},
		
		//查詢
		doQuery:function(){
			valid1.reset();
			valid2.reset();
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			
			if( !valid1.validate() ) {
	    		return;
	    	}	
	    	
	    	//檢核當查詢條件只有縣市別(CITY、TOWN)時，至少要輸入另一個查詢條件避免因資料過多查詢時間過久
	    	var chkMap = {};
			$$('#tableA input').each(function(o){
				if(o.type != 'button' && o.value != ''){
					chkMap[o.id] = o.value;
				}
			});
			$$('#tableA select').each(function(o){
				//USE_AREA1、RST_KIND、USE_FOR預設值為0，CITY、TOWN預設值為''
				if(o.id != 'EQU_SIGN' && o.value != '0'){
					chkMap[o.id] = o.value;
				}
			});
			var hasDefaultValueField = ['r_areaCodeQuery', 'r_query'];
			var hasCityTown = false;
			var hasOtherField = false;
			for(var key in chkMap){
				if(key == 'TOWN' || key == 'CITY'){
					hasCityTown = true;
				}else if (!hasDefaultValueField.includes(key)){
					hasOtherField = true;
				}
				if(hasOtherField){
					break;
				}
			}
			if (hasCityTown && !hasOtherField) {
				alert("當查詢條件只有縣市別時，至少要輸入另一個查詢條件");
				return;
			}
	    	
	    	var reqMap = commonTools.getInputData();
	    	
	    	var actionName = 'DSA3_2400'=='${fromPublicBean}' ? 'queryByDSA3_0900' : 'query';
	    	
			ajaxPost(actionName,{reqMap:Object.toJSON(reqMap)},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
				},
				function(){
					grid.load([]);
				}
			);
		},
		
		//土建融查詢
		doLandQuery:function(){
			valid1.reset();
			valid2.reset();
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			
			//查詢條件：受理編號、買賣日期、鑑價日期、縣市別、地址路名門牌、地坪、建築完成日
			if(!checkInput.landQuery()){
				return;
			}
			
			if( !valid1.validate() ) {
	    		return;
	    	}	
	    	
	    	//檢核當查詢條件只有縣市別(CITY、TOWN)時，至少要輸入另一個查詢條件避免因資料過多查詢時間過久
	    	var chkMap = {};
	    	//受理編號、買賣日期、鑑價日期、地址路名門牌、地坪、建築完成日
			$$('#tableA input').each(function(o){
				if(o.type != 'button' && o.value != ''){
					chkMap[o.id] = o.value;
				}
			});
			$$('#tableA select').each(function(o){
				//USE_AREA1、RST_KIND、USE_FOR預設值為0，CITY、TOWN預設值為''
				if(o.id != 'EQU_SIGN' && o.value != '0'){
					chkMap[o.id] = o.value;
				}
			});
			var hasDefaultValueField = ['r_areaCodeQuery', 'r_query'];
			var hasCityTown = false;
			var hasOtherField = false;
			for(var key in chkMap){
				if(key == 'TOWN' || key == 'CITY'){
					hasCityTown = true;
				}else if (!hasDefaultValueField.includes(key)){
					hasOtherField = true;
				}
				if(hasOtherField){
					break;
				}
			}
			if (hasCityTown && !hasOtherField) {
				alert("當查詢條件只有縣市別時，至少要輸入另一個查詢條件");
				return;
			}
	    	
	    	var reqMap = commonTools.getInputData();
	    	
	    	var actionName = 'DSA3_2400'=='${fromPublicBean}' ? 'landQueryByDSA3_0900' : 'landQuery';
	    	
			ajaxPost(actionName,{reqMap:Object.toJSON(reqMap)},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
				},
				function(){
					grid.load([]);
				}
			);
		},
		
		//整批分戶查詢
		doGroupQuery:function(){
			valid1.reset();
			valid2.reset();
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			
			//查詢條件：受理編號、買賣日期、鑑價日期、縣市別、地址路名門牌、案名、建築完成日
			if(!checkInput.groupQuery()){
				return;
			}
			
			if( !valid1.validate() ) {
	    		return;
	    	}	
	    	
	    	var reqMap = commonTools.getInputData();
	    	
	    	var actionName = 'DSA3_2400'=='${fromPublicBean}' ? 'groupQueryByDSA3_0900' : 'groupQuery';
	    	
			ajaxPost(actionName,{reqMap:Object.toJSON(reqMap)},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
				},
				function(){
					grid.load([]);
				}
			);
		},
		
		//社區資料查詢
		doCommunityQuery:function(){
			valid1.reset();
			valid2.reset();
			
			//查詢條件：縣市別、地址路名門牌、案名、建築完成日
			if(!checkInput.communityQuery()){
				return;
			}
			
			if( !valid2.validate() ) {
	    		return;
	    	}	
	    	
	    	//檢核當查詢條件只有縣市別(CITY、TOWN)時，至少要輸入另一個查詢條件避免因資料過多查詢時間過久
	    	var chkMap = {};
	    	//受理編號、買賣日期、鑑價日期、地址路名門牌、地坪、建築完成日
			$$('#tableA input').each(function(o){
				if(o.type != 'button' && o.value != ''){
					chkMap[o.id] = o.value;
				}
			});
			$$('#tableA select').each(function(o){
				//USE_AREA1、RST_KIND、USE_FOR預設值為0，CITY、TOWN預設值為''
				if(o.id != 'EQU_SIGN' && o.value != '0'){
					chkMap[o.id] = o.value;
				}
			});
			if (Object.keys(chkMap).length == 2) {
				//若chkMap中只有CITY、TOWN(size == 2)，表示沒有輸入其它查詢條件
				alert("當查詢條件只有縣市別時，至少要輸入另一個查詢條件");
				return;
			}
	    	
	    	var reqMap = commonTools.getInputData();
	    	
	    	var actionName = 'DSA3_2400'=='${fromPublicBean}' ? 'communityQueryByDSA3_0900' : 'communityQuery';
	    	
			ajaxPost(actionName,{reqMap:Object.toJSON(reqMap)},
				function(resp){
					grid.load(resp.rtnList?resp.rtnList:[]);
				},
				function(){
					grid.load([]);
				}
			);
		},
		
		//清除
		doClear:function(){
			$('form1').reset();
			$('TOWN').update().insert(new Element('option', {value: ""}).update("鄉鎮區"));
			actions.resetTableC();
		},
		
		//編號超連結
		doWindowOpen:function(QUERY_TYPE, APPLY_ID){
			 if('4' == QUERY_TYPE){//社區資料庫
			 	popupWin.windowOpen('<%=dispatcher%>/DSA3_3310/prompt',{
	        		'parameters': {'COMMUNITY_NO': APPLY_ID},
					'windowName': APPLY_ID.replace('@', "")
	    		});
			 }else{
			 	var link  = '';
				if('1' == QUERY_TYPE){//鑑價報告
					link  = 'DSA3_0500';				
				}else if('2' == QUERY_TYPE){//土建融鑑價報告
					link  = 'DSA3_0600';				
				}else if('3' == QUERY_TYPE){//整批分戶鑑價報告
					link  = 'DSA3_0700';
				}else{
					return;
				}				
				popupWin.windowOpen('<%=dispatcher%>/'+link+'/prompt',{
	        		'parameters': {'APPLY_ID': APPLY_ID},
					'windowName':  APPLY_ID.replace('@', "")
	    		});
			 }
		},
		
		//取得鄉鎮區
		doGetTOWN_LIST:function(){
			var selectElement = $('TOWN');
			selectElement.update().insert(new Element('option', {value: ""}).update("鄉鎮區"));
			var val = $F('CITY') ;
			if(val == ''){
				return;
			}
			//已查詢過就不用再做查詢
			if(TOWN_Map[val]&&TOWN_Map[val].length > 0){
				var opts = TOWN_Map[val];
				if(opts){
					opts.each(function(opt){
						selectElement.insert(new Element('option', {value: opt.TOWN_NAME}).update(opt.TOWN_NAME));
					});
				}				
			}else{
				ajaxPost('getTOWN_LIST',{CITY_NAME : val},
					function(resp){
							var opts = resp.TOWN_LIST;
							TOWN_Map[val] = opts;
							if(opts){
								opts.each(function(opt){
									selectElement.insert(new Element('option', {value: opt.TOWN_NAME}).update(opt.TOWN_NAME));
								});
							}
							
					}
				);
			}		
		},
		//切換承作分區查詢
		functionSwitch:function(text){
			var title = '';
			actions.doClear();//畫面清空
			
			if('r_query' == text){//擔保品查詢頁
				title = '擔保品行情查詢';
				view_type = 'query';
				$$('.tr_for_price_query').forEach(function(ele) {
					ele.show();
	            });
				$$('.tr_for_areaCode_query').forEach(function(ele) {
					ele.hide();
	            });
				//處理畫面上輸入框、下拉選單
				$$('.ele_for_price_query').each(function (elem) {
					elem.enable();
					elem.show();
				});
				$$('.ele_for_areaCode_query').each(function (elem) {
					elem.disable();
					elem.hide();
				});
				$('grid').show();
				$('tableC').hide();
				$('ADDR_NO').removeAttribute("placeholder");//placeholder setting
			} else if('r_areaCodeQuery' == text){//承作分區查詢頁
			   title = '承作分區查詢';
			   view_type = 'areaCodeQuery';
				$$('.tr_for_price_query').forEach(function(ele) {
					ele.hide();
				});
			    $$('.tr_for_areaCode_query').forEach(function(ele) {
					ele.show();
				});
				//處理畫面上輸入框、下拉選單
				$$('.ele_for_price_query').each(function (elem) {
					elem.disable();
					elem.hide();
				});
				$$('.ele_for_areaCode_query').each(function (elem) {
					elem.enable();
					elem.show();
				});
				
				//承作分區查詢相關輸入項目
	           $('grid').hide();
	           $('tableC').show();
	           $('ADDR_NO').setAttribute("placeholder", "請輸入完整門牌");//placeholder setting
			}
			$(text).checked = true; 
			$$('.contentsTh span')[0].innerHTML = title;
			
			var btnRowSpan;
			if('r_query' == text){//擔保品查詢頁
				btnRowSpan = 7;
				<c:if test="${showApplyId ne true}">
					btnRowSpan = 6;
				</c:if>
			}else if('r_areaCodeQuery' == text){//承作分區查詢頁
				btnRowSpan = 3;
			}
			$('A1_TD_BTN').rowSpan = btnRowSpan;
			
		},//承作分區查詢
		doAreaCodeQuery:function(){
			valid3.reset();
			actions.resetTableC();
			if( !valid3.validate() ) {
	    		return;
	    	}
			
			var reqMap = commonTools.getInputData4AreqCodeQuery();
			ajaxPost('areacodeQuery',{reqMap:Object.toJSON(reqMap)},
				function(resp){//success
					actions.setAreaCodeResult(resp.rtnMap);
				},
				function(){//fail
					actions.setAreaCodeResult();
				}
			);
		},//reset 承作分區查詢結果
		resetTableC:function(){
			$('SUBMKT_NAME').innerHTML ='';
			$('AREA_CODE_930318').innerHTML ='';
			$('MEMO').innerHTML ='';
			
			if(view_type == 'areaCodeQuery'){
				$('r_areaCodeQuery').checked = true;
			} else if(view_type == 'query' || !view_type){
				$('r_query').checked = true;
			}
		},//取得承作分區查詢結果
		setAreaCodeResult:function(map){
			if(map){
				$('SUBMKT_NAME').innerHTML = map.SUBMKT_NAME;
				$('AREA_CODE_930318').innerHTML = map.AREA_CODE_930318;
				$('MEMO').innerHTML = map.MEMO;
			} else {
				$('SUBMKT_NAME').innerHTML ='';
				$('AREA_CODE_930318').innerHTML ='';
				$('MEMO').innerHTML ='';
			}
		}
	};
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		beanName = 'DSA3_2400'=='${fromPublicBean}' ? '${fromPublicBean}' : 'DSA3_0900';
		new Ajax.Request( "<%=dispatcher%>/"+beanName+"/" + actionName,	
    	{ 	
	    	parameters: params, 	    	
	        onSuccess: function(XHT,resp){
				if(CSRUtil.isSuccess(resp)){
					if(successAction){
		 				successAction(resp);
		 			}
				}else if(errorAction){
		 			errorAction(resp);
		 		}
	        }}
		);
	}

	var commonTools = {			
		
		//取得A區塊資料
		getInputData:function(){
			var dataMap = {};
			$$('#tableA input','#tableA select').each(function(o){
				if(o.type != 'button'){
					dataMap[o.id] = o.value;
				}
			});
			dataMap.APPR_DATE_BEG = toY2K(dataMap.APPR_DATE_BEG);
			dataMap.APPR_DATE_END = toY2K(dataMap.APPR_DATE_END);
			dataMap.TRADE_DATE_BEG = toY2K(dataMap.TRADE_DATE_BEG);
			dataMap.TRADE_DATE_END = toY2K(dataMap.TRADE_DATE_END);
			dataMap.FINISH_DATE_BEG = toY2K(dataMap.FINISH_DATE_BEG);
			dataMap.FINISH_DATE_END = toY2K(dataMap.FINISH_DATE_END);
			dataMap.showApplyId = showApplyId;

			return dataMap;
		},
		//取得承作分區查詢資料
		getInputData4AreqCodeQuery:function(){
			var dataMap = {};
			dataMap.CITY = $F('CITY');
			dataMap.TOWN = $F('TOWN');
			dataMap.ADDR_NO = $F('ADDR_NO');
			dataMap.LONGITUDE = $F('LONGITUDE');
			dataMap.LATITUDE = $F('LATITUDE');
			return dataMap;
		}
	};
	
	var checkInput = {

		landQuery:function(){
			var str = '';
			//案名、總樓層
			$w('CASE_NAME FLOOR').each(
				function(id){
					if($F(id) != ''){
						str += ($(id).getAttribute('fieldName') + '、');
					}
				}
			);

			//類別、使用分區、列管區
			$w('USE_FOR USE_AREA1 RST_KIND').each(
				function(id){
					if($F(id) != '0'){
						str += ($(id).getAttribute('fieldName') + '、');
					}
				}
			);
			
			
			//屋齡區間 建坪
			$w('BUILD_AGE BUILD_MEASURE').each(
				function(id){
					if($F(id+'1') != '' || $F(id+'2') != ''){
						str += ($(id).getAttribute('useKindName') + '、');
					}
				}
			);			
						
			if(str == ''){
				return true;
			}else{
				alert('土建融案件無法以' + str.substring(0,str.length-1)+'查詢資料');
				return false;
			}
		},
		
		groupQuery:function(){
		
			var str = '';
			//總樓層
			$w('FLOOR').each(
				function(id){
					if($F(id) != ''){
						str += ($(id).getAttribute('fieldName') + '、');
					}
				}
			);

			//類別、使用分區、列管區
			$w('USE_FOR USE_AREA1 RST_KIND').each(
				function(id){
					if($F(id) != '0'){
						str += ($(id).getAttribute('fieldName') + '、');
					}
				}
			);
			
			
			//屋齡區間、地坪、建坪
			$w('BUILD_AGE LAND_MEASURE BUILD_MEASURE').each(
				function(id){
					if($F(id+'1') != '' || $F(id+'2') != ''){
						str += ($(id).getAttribute('useKindName') + '、');
					}
				}
			);			
						
			if(str == ''){
				return true;
			}else{
				alert('整批分戶案件無法以' + str.substring(0,str.length-1)+'查詢資料');
				return false;
			}
		},
		
		communityQuery:function(){
		
			var str = '';
			//受理編號、總樓層、買賣日期、鑑價日期
			$w('APPLY_ID FLOOR TRADE_DATE_BEG TRADE_DATE_END APPR_DATE_BEG APPR_DATE_END').each(
				function(id){
					if($F(id) != ''){
						str += ($(id).getAttribute('fieldName') + '、');
					}
				}
			);

			//類別、使用分區、列管區
			$w('USE_FOR USE_AREA1 RST_KIND').each(
				function(id){
					if($F(id) != '0'){
						str += ($(id).getAttribute('fieldName') + '、');
					}
				}
			);
			
			
			//屋齡區間、地坪、建坪
			$w('BUILD_AGE LAND_MEASURE BUILD_MEASURE').each(
				function(id){
					if($F(id+'1') != '' || $F(id+'2') != ''){
						str += ($(id).getAttribute('useKindName') + '、');
					}
				}
			);			
						
			if(str == ''){
				return true;
			}else{
				alert('社區資料無法以' + str.substring(0,str.length-1)+'查詢資料');
				return false;
			}
		}
		
	};

	return{                              
		initApp:function(){
			PageUI.createPage("DSA30900" , "鑑價作業" , "擔保品行情查詢", false);
			PageUI.loadin(["form1","grid","tableC"] ,1);

			//A1區、B1區不顯示,不顯示受理編號
			<c:if test="${showApplyId ne true}">
				$('A1_TR_1').hide();
				//不顯示受理編號、買賣日、買賣價、租金
				gridColumn =  gridColumn.slice(1,gridColumn.length-2);
				var tmpGrid=[];
				var k=0;
				for(var i=0;i<gridColumn.length;i++){
					if(gridColumn[i]['key']!='TRADE_DATE' && gridColumn[i]['key']!='BUILD_AGE'){
						tmpGrid[k++]=gridColumn[i];
					}
					if(gridColumn[i]['key']=='BUILD_AGE'){
						tmpGrid[k++]=						
						{header: "屋齡" ,key: "BUILD_AGE" , attrs:{rowSpan:2} ,
		               		render:function(record,value){
		               			if(record.BUILD_AGE == undefined){
		               				value = '無屋齡';
		               			}
		               		 	return  value;
		               		}
		            	};
					}
				}
				gridColumn=tmpGrid;
			</c:if>
			
			grid = new TableUI ( {
				table: $("grid"), pageSize: 10, allSortable:true,split: ['BUILD_MEASURE'], 
					column:gridColumn
				
			});	
						
			valid1 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				['validateBetween', '迄值不得小於起值', function(v , node) { 
					var v2 = parseInt(v,10);
					var v1 = parseInt($F(node.name+'1'),10);
					if(isNaN(v1)  || isNaN(v2) ){
						return true ;
					}else{
						return v2 >= v1 ;
					}

				}],
				['validateAddr_No', '地址路名門牌與縣市別需擇一輸入', function(v , node) { 
					if(!$F('APPLY_ID') && $F('ADDR_NO') == '' && $F('CITY') == '' ){
						return false;
					}else{
						return true;
					}
				}]	
			]);
			valid1.define( "validateAddr_No" , { id: "CITY" } );
			valid1.define( "validateAddr_No" , { id: "ADDR_NO" } );
			
			valid2 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				['validateCase_Name', '案名與縣市別需擇一輸入', function(v , node) { 
					if($F('CASE_NAME') == '' && $F('CITY') == '' ){
						return false;
					}else{
						return true;
					}
				}]	
			]);
			valid2.define( "validateCase_Name" , { id: "CITY" } );
			valid2.define( "validateCase_Name" , { id: "CASE_NAME" } );
			
			valid3 = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese([
				['validateAddrAndLon', '【地址路名門牌】與【經度、緯度】需擇一輸入', function(v , node) { 
					if($F('ADDR_NO') == '' && ($F('LONGITUDE') == '' || $F('LATITUDE') == '')){
						return false;
					} else if($F('ADDR_NO') != '' && ($F('LONGITUDE') != '' || $F('LATITUDE') != '')) {
						return false;
					} else {
						return true;
					}
				}],
				['validateFullAddrNo', '使用地址查詢，請輸入完整門牌', function(v , node) { 
					if($F('ADDR_NO') != ''){
						if( $F('ADDR_NO').indexOf('號') < 0 ){
							$('MEMO').innerHTML = '請輸入完整門牌進行查詢';
							return false;
						}
						return true;
					} else {
						return true;
					}
				}]
			]);
			valid3.define( "validateAddrAndLon" , { id: "ADDR_NO" } );
			valid3.define( "validateFullAddrNo" , { id: "ADDR_NO" } );
			valid3.define( "required" , [{ id: "CITY"},{ id: "TOWN" }] );	
			//查詢
			$('btn_query').observe('click',function(event){
					actions.doQuery();
				}
			);
			
			//土建融查詢
			$('btn_landQuery').observe('click',function(event){
					actions.doLandQuery();
				}
			);
		
			// 整批分戶查詢
			$('btn_qroupQuery').observe('click',function(event){
					actions.doGroupQuery();
				}
			);
			
			// 社區資料查詢
			$('btn_communityQuery').observe('click',function(event){
					actions.doCommunityQuery();
				}
			);
			
			//清除
			$('btn_clear').observe('click',function(event){
					actions.doClear();
				}
			);
			
			//「縣市別」下拉選單連動 「鄉鎮區」下拉選單
			$('CITY').observe('change',function(event){
					actions.doGetTOWN_LIST();
				}
			);	
			//20240617 ie不支援array.include，故先檢查是否支援，若不支援則自行定義
			if (!Array.prototype.includes) {
				  Object.defineProperty(Array.prototype, 'includes', {
				    value: function (searchElement, fromIndex) {

				      if (this == null) {
				        throw new TypeError('"this" is null or not defined');
				      }

				      // 1. Let O be ? ToObject(this value).
				      var o = Object(this);

				      // 2. Let len be ? ToLength(? Get(O, "length")).
				      var len = o.length >>> 0;

				      // 3. If len is 0, return false.
				      if (len === 0) {
				        return false;
				      }

				      // 4. Let n be ? ToInteger(fromIndex).
				      //    (If fromIndex is undefined, this step produces the value 0.)
				      var n = fromIndex | 0;

				      // 5. If n >= 0, then
				      //  a. Let k be n.
				      // 6. Else n < 0,
				      //  a. Let k be len + n.
				      //  b. If k < 0, let k be 0.
				      var k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);

				      function sameValueZero(x, y) {
				        return x === y || (typeof x === 'number' && typeof y === 'number' && isNaN(x) && isNaN(y));
				      }

				      // 7. Repeat, while k < len
				      while (k < len) {
				        // a. Let elementK be the result of ? Get(O, ! ToString(k)).
				        // b. If SameValueZero(searchElement, elementK) is true, return true.
				        if (sameValueZero(o[k], searchElement)) {
				          return true;
				        }
				        // c. Increase k by 1.
				        k++;
				      }

				      // 8. Return false
				      return false;
				    }
				  });
				}
			//承作分區查詢
			$('btn_areaCodeQuery').observe('click', actions.doAreaCodeQuery);
			//功能切換radio
			$('r_query').observe('click', function(){actions.functionSwitch('r_query')});
			$('r_areaCodeQuery').observe('click', function(){actions.functionSwitch('r_areaCodeQuery')});
			
			$('r_query').checked = true; 
			actions.functionSwitch('r_query');
			
            displayMessage();
            
			if('${param.APPLY_ID}'!=''){
				$('APPLY_ID').value = '${param.APPLY_ID}';
				actions.doPromptQuery();
			}

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
		
<!------------------------ A區--------------------->	
			<form id="form1" name="form1" method="post">
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<tr>
					<td class="tbYellow" colspan="6">
						<input name="functionSwitch" id="r_query" type="radio" value='0'>擔保品行情查詢
						<input name="functionSwitch" id="r_areaCodeQuery" type="radio" value='1'>承作分區查詢
					</td>
					<td class="tbYellow2" rowSpan="5" align="center" width="10%" id="A1_TD_BTN">
						<input id="btn_areaCodeQuery" name="btn_areaCodeQuery" style="width:90px" type="button" class="button ele_for_areaCode_query" value="承作分區查詢" />
						<input id="btn_query" name="btn_query" type="button" class="button ele_for_price_query" value="查詢" />
						<input id="btn_landQuery" name="btn_landQuery" style="width:90px" type="button" class="button ele_for_price_query" value="土建融查詢" />
						<input id="btn_qroupQuery" name="btn_qroupQuery" style="width:90px" type="button" class="button ele_for_price_query" value="整批分戶查詢" />
						<input id="btn_communityQuery" name="btn_communityQuery" style="width:90px" type="button" class="button ele_for_price_query" value="社區資料查詢" />
						<br><input id="btn_clear" name="btn_clear" type="button" class="button" value="清除" />
					</td>
				</tr>
				<tr id="A1_TR_1" <c:if test="${showApplyId eq true}">class="tr_for_price_query"</c:if>>
					<td class="tbYellow" >受理編號</td>
					<td class="tbYellow2">
						<input id="APPLY_ID" name="APPLY_ID" type="text" fieldName="受理編號" class="textBox2 checkInputLength ele_for_price_query" size="15" maxlength="11" />
					</td>
					<td class="tbYellow" >買賣日期</td>
					<td class="tbYellow2" colspan="3">
						<input type="text" datatype="ROCDate" fieldName="買賣日期(起)" class="textBox2 validate-ROCDate ele_for_price_query" size="8" maxlength="7" name="TRADE_DATE_BEG" id="TRADE_DATE_BEG" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('TRADE_DATE_BEG'))">
						~
						<input type="text" datatype="ROCDate" fieldName="買賣日期(訖)" class="textBox2 validate-ROCDate ele_for_price_query" size="8" maxlength="7" name="TRADE_DATE_END" id="TRADE_DATE_END" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('TRADE_DATE_END'))">
					</td>
				</tr>
	 			<tr class="tr_for_price_query">
	 				<td class="tbYellow" width="13%" >鑑價日期</td>
					<td class="tbYellow2" width="29%" > 
						<input type="text" datatype="ROCDate" fieldName="鑑價日期(起)" class="textBox2 validate-ROCDate ele_for_price_query" size="8" maxlength="7" name="APPR_DATE_BEG" id="APPR_DATE_BEG" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('APPR_DATE_BEG'))">
						~
						<input type="text" datatype="ROCDate" fieldName="鑑價日期(訖)" class="textBox2 validate-ROCDate ele_for_price_query" size="8" maxlength="7" name="APPR_DATE_END" id="APPR_DATE_END" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('APPR_DATE_END'))">
					</td>
                    <td class="tbYellow" width="16%" >使用分區</td>
                    <td class="tbYellow2" width="10%" >
						<select name="USE_AREA1" id="USE_AREA1"  fieldName="使用分區" class="ele_for_price_query">
							<c:forEach var="map" items="${USE_AREA1_LIST}">
								<option value="${map.key}"><c:choose><c:when test="${map.key eq '0'}">全部</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
					</td>
                    <td class="tbYellow" width="12%" >列管區</td>
                    <td class="tbYellow2" width="10%" >
						<select name="RST_KIND" id="RST_KIND" fieldName="列管區" class="ele_for_price_query">
							<c:forEach var="map" items="${RST_KIND_LIST}">
								<option value="${map.key}"><c:choose><c:when test="${map.key eq '0'}">全部</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
					</td>
                </tr>
	 			<tr>
                    <td class="tbYellow">縣市別</td>
                    <td class="tbYellow2">
						<select name="CITY" id="CITY" fieldName="縣市別">
							<option value="">縣市別</option>
							<c:forEach var="map" items="${CITY_LIST}">
								<option value="${map.CITY_NAME}">${map.CITY_NAME}</option>
							</c:forEach>
						</select>
						<select name="TOWN" id="TOWN" fieldName="鄉鎮區">
							<option value="">鄉鎮區</option>
						</select>
					</td>
    
					<td class="tbYellow">地址路名門牌</td>
					<td class="tbYellow2" colspan="3">
						<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						<input id="ADDR_NO" name="ADDR_NO" type="text" fieldName="地址路名門牌" class="textBox2" size="35" alt="ch">
					</td>
                </tr>
                <tr class="tr_for_areaCode_query">
                	<td class="tbYellow">經度</td>
                    <td class="tbYellow2">
                    	<input name="LONGITUDE" id="LONGITUDE" size="32" type="text" fieldName="經度" class="textBox2 ele_for_areaCode_query" placeholder="精確至小數第6位(例:121.553012)">
					</td>
    
					<td class="tbYellow">緯度</td>
					<td class="tbYellow2" colspan="3">
						<input name="LATITUDE" id="LATITUDE" size="32" type="text" fieldName="緯度" class="textBox2 ele_for_areaCode_query" placeholder="精確至小數第6位(例:25.033021)" >
					</td>
                </tr>
	 			<tr class="tr_for_price_query">
                    <td class="tbYellow">總樓層</td>
                    <td class="tbYellow2">
						<select name="EQU_SIGN" id="EQU_SIGN" class="ele_for_price_query">
							<c:forEach var="map" items="${EQU_SIGN_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
						<input id="FLOOR" name="FLOOR" type="text" fieldName="總樓層" class="textBox2 validate-digits ele_for_price_query" size="4" >
					</td>
                    <td class="tbYellow">類別</td>
                    <td class="tbYellow2">
						<select name="USE_FOR" id="USE_FOR" fieldName="類別" class="ele_for_price_query">
							<c:forEach var="map" items="${USE_FOR_LIST}">
								<option value="${map.key}"><c:choose><c:when test="${map.key eq '0'}">全部</c:when><c:otherwise>${map.value}</c:otherwise></c:choose></option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow">屋齡區間</td>
					 <td class="tbYellow2">
					<input id="BUILD_AGE1" name="BUILD_AGE" type="text" fieldName="屋齡區間(起)" useKindName="屋齡區間" class="textBox2 validate-digits validateBetween ele_for_price_query" size="4" />~
					<input id="BUILD_AGE2" name="BUILD_AGE" type="text" fieldName="屋齡區間(訖)" useKindName="屋齡區間" class="textBox2 validate-digits validateBetween ele_for_price_query" size="4" />
					</td>
                </tr>
 	 			<tr class="tr_for_price_query">
                    <td class="tbYellow">案名</td>
                    <td class="tbYellow2">
						<input id="CASE_NAME" name="CASE_NAME" type="text" class="textBox2 ele_for_price_query" size="15" fieldName="案名" />
					</td>            
					<td class="tbYellow">地坪</td>
					 <td class="tbYellow2">
					<input id="LAND_MEASURE1" name="LAND_MEASURE" type="text" fieldName="地坪(起)" useKindName="地坪" class="textBox2 validate-digits validateBetween ele_for_price_query" size="6" />~
					<input id="LAND_MEASURE2" name="LAND_MEASURE" type="text" fieldName="地坪(訖)" useKindName="地坪" class="textBox2 validate-digits validateBetween ele_for_price_query" size="6" />
					</td>
					<td class="tbYellow">建坪</td>
					 <td class="tbYellow2">
					<input id="BUILD_MEASURE1" name="BUILD_MEASURE" type="text" fieldName="建坪(起)" useKindName="建坪" class="textBox2 validate-digits validateBetween ele_for_price_query" size="6" />~
					<input id="BUILD_MEASURE2" name="BUILD_MEASURE" type="text" fieldName="建坪(訖)" useKindName="建坪" class="textBox2 validate-digits validateBetween ele_for_price_query" size="6" />
					</td>
                </tr>
 	 			<tr class="tr_for_price_query">
                    <td class="tbYellow">建築完成日</td>
                    <td class="tbYellow2" colspan="5">
						<input type="text" datatype="ROCDate" fieldName="建築完成日(起)" class="textBox2 validate-ROCDate ele_for_price_query" size="8" maxlength="7" name="FINISH_DATE_BEG" id="FINISH_DATE_BEG" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('FINISH_DATE_BEG'))">~
						<input type="text" datatype="ROCDate" fieldName="建築完成日(訖)" class="textBox2 validate-ROCDate ele_for_price_query" size="8" maxlength="7" name="FINISH_DATE_END" id="FINISH_DATE_END" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('FINISH_DATE_END'))">
					</td>            
				</tr>
				<td colspan="7" class="tbYellow2 tr_for_price_query">
				※<font color='red'>＊＊</font>表示擔保品有增建情形。
				<font color='blue'>＠＠</font>表示同一編號含兩筆以上門牌(主建號)。
				<font color='green'>＄＄</font>表示擔保品為非承作區或列管區。
				</td>
				<tr>
				</tr>
			</table>
			</form>
<!------------------------ B區--------------------->											
			<table id="grid" class="grid"></table>
<!-- -------------------C區 (承作分區查詢使用)-->
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableC">
	<tr><th colspan="5" align="left">承作分區查詢結果</th></tr>
	<tr>
       <td class="tbBlue" width="50%" align="center">所在生活圈</td>
       <td class="tbYellow2" id="SUBMKT_NAME"></td>
    </tr>
    <tr>
       <td  class="tbBlue" align="center">承作分區</td>
       <td  class="tbYellow2" id="AREA_CODE_930318"></td>
	</tr>
    <tr>
     	<td class="tbBlue" align="center">備註</td>
     	<td class="tbYellow2" colspan="2" id="MEMO"></td>
   	</tr>

</table>
</body>
<!-- InstanceEnd -->
</html>