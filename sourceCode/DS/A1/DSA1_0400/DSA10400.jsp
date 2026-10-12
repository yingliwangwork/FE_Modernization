<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--
    Date        Version Description                         Author
    2011/08/22  1.0     Created                             林今富
                        (待補模組及連結頁面清單:
                        1.  地址門牌下拉選單模組DSZ01000.jsp
                        2.  影像-連結DP頁面DSA0_0100
                        3.  影像-連結AV頁面DSA0_0200
                        4.  BPM相關維護模組DS_Z0Z010)

    程式功能概要說明：
    程式功能　土地謄本輸入作業
    程式名稱　DSA1_0400.java
    作業方式　ONLINE
    概要說明　
    功能說明:(1) 查詢作業 ─ 依據查詢條件，透過模組取得資料庫內之土地謄本資料(受理案件主檔DTDSA010、土地謄本資料檔DTDSA040、鑑價報告檔DTDSA200)，顯示查詢結果於畫面。
            (2) 新增作業 ─ 使用者按下新增按鈕後，將土地謄本資料新增至資料庫中(土地謄本資料檔DTDSA040)。
            (3) 刪除作業 ─ 使用者按下刪除按鈕後，將該資料由資料庫中刪除(土地謄本資料檔DTDSA040)。
            (4) 修正作業 ─ 使用者按下修改按鈕後，將畫面資料存進資料庫中(土地謄本資料檔DTDSA040)。
            (5) 修正地號作業 ─ 使用者按下修改地號按鈕後，將畫面修改後之地號欄位存進資料庫中(土地謄本資料檔DTDSA040)。
            (6) 清除作業 ─ 清空頁面欄位資料並給予初始值。
            (7) 退回作業 ─ 使用者按下退回按鈕後，將此筆資料於BPM流程中的進度，退回至服務中心處理。
            (8) 取消取件作業 ─ 使用者按下取消取件按鈕後，將此筆資料於BPM流程中的進度取消鎖件。
            (9) 土地謄本影像作業 ─ 使用者按下土地謄本影像按鈕後，連結至影像-連結AV作業畫面查詢。
            (10)    拆件影像作業 ─ 使用者按下拆件影像按鈕後，連結至影像-連結DP作業畫面查詢。
    按鈕授權　FUNC_ID = DSA10400
    
    [20210311] 修改件
    1.新增銀行件修改功能，僅可修改移轉年月、前次移轉現值、使用分區。可複製修改內容再修改
    
    [20210323] 問題單 20210323101940
    1. 銀行件判斷條件:受理編號第4碼為“@” AND 受理編號第4,5碼 != “@A” “@B” “@E”
	2. 銀行件修改僅能修改使用分區
	[20250217]調整
	[20250221]調整單/多選方式取得更新資料方法
	[20250306]新增收折土地訊息區塊、自動預帶第一筆地號資料
	@author 楊宗翰
	@since 2011-09-15
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5">
<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css">

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/AlertHandler.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/comm.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/Validator.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/core.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/ui.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/ui/commView.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/utility.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>
<%--[20240722]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/JavaScript">

<!--
Event.observe(window, 'load', initApp);

// tableUI
var grid,grid0;

// DSZ01000
var address3

// 檢核
var validator;

var checkedSEQ_NO = '1';
var userId;
var is2Q_PERSON;
var maxSEQ_NO = "0";
var rtnMap;
var record;
var oldValue = {};
var address_id = "DSZ01000";
var recordForCheckFast = {};<%--[20210311]方便快速檢核欄位是否有異動--%>
var radio_sn = '';<%--[20250217]--%>
var USE_SECT_Map = <c:out value="${USE_SECT_Map_JSON}" default="{}" escapeXml="false" />;
var USE_KIND_Map = <c:out value="${USE_KIND_Map_JSON}" default="{}" escapeXml="false" />;
var SECT_SEQ_NO = '';<%--[20250221] 新增單選當下資料序號--%>

// pattern
var pattern_time = /(\d+)-(\d+)-(\d\d) (\d+):(\d+)/;	// 日期格式
var pattern_date = /(\d+)-(\d+)-(\d\d)/;	// 日期格式(date)
var pattern_month = /(\d+)-(\d+)/;	// 日期格式(month)
var pattern_money = "#,###";	// 金額格式(無小數)
var pattern_money2 = "#,###.##";	// 金額格式(小數2位)

//--------------------------------------------------------------------------
// 按鈕權限設定
//--------------------------------------------------------------------------
function buttonAuth(){
	var authButtons = {
		B0003:'btn_add',<%--新增--%>
		B0004:'btn_update',<%--修改--%>
		B0005:'btn_delete',<%--刪除--%>
		B0022:'btn_update_LAND_NO',<%--修改地號--%>
		B0023:'btn_cancel',<%--取消取件--%>
		B0024:'btn_link1',<%--土地謄本影像--%>
		B0025:'btn_link2'<%--拆件影像--%>
	};
	<dz:grantButtons FUNC_ID="DSA10400" ignored="false"/>
}

function initApp(){
	//日期、數字輸入自動格式化
	autoFormatToDate();
	autoFormatToNumber();
	PageUI.createPageWithAllBodySubElement("DSA10400", "受理作業", "土地謄本輸入作業", null, '${param.titleNotDisplay}' == 'Y');
	
	buttonAuth();
	validator = new Validator();
	new UI().init();

}

function UI(){
	return {
		init:function() {
			displayMessage();

			grid = new TableUI({
				table: $('grid'), pageSize: 1, allSortable: false,
				<%-- 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange:function(pageNO){
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					var record_no = pageNO - 1;
					var allRecords = grid.getAllRecords();
					if(record_no < 0 || record_no >= allRecords.length ){ return;}
					
					record = allRecords[record_no];
					layout.createDetail();
				},
				column:[
					{header:'序號', key:'SEQ_NO'},
					{header:'地號', key:'LAND_NO1',
						render:function(record, value){
							var LAND_NO1 = formatInput.text(record.LAND_NO1, false);
							var LAND_NO2 = formatInput.text(record.LAND_NO2, false);

							return LAND_NO1 + " - " + LAND_NO2;
						}
					},
					{header:'所有權人', key:'NAME', attrs:{style:"font-family:'EUDC'"} },<%--[20240723]難字調整 --%>
					{header:'移轉年月', key:'TRAN_DATE',
						render:function(record, value){
							var result = (!value) ? '':value.match(pattern_month);
							return formatInput.Y2KMonth2ROCMonth(result[0], "/");
						}
					}
				]
			});
			<%--[20250217]B0區--%>
			grid0 = new TableUI({
				table: $('grid0'), pageSize: 10, allSortable: false,
				pageChange: function(){
					if(radio_sn != ''){
						setTimeout(function(){
							var radio = $('grid0_radio'+radio_sn);		
							if(radio){
								radio.checked = true;
								radio.simulate('click');
							}
						}, 100);
					}
				},
				autoCheckBox:{
					isSelectAll: true,
					type:'checkbox',
					text:'批次選取',
					insertPosition:1,
					action: function( node, boxStatus, records ){ 
						if(boxStatus){
							actions.doCheckRadio();
						}			
					}
				},
				column:[
					{header: '選取', key: '',
						render:function(rec, val, sn){
							var radio = new Element('input', {type:'radio', id:'grid0_radio'+sn, name:'grid0_radio'});
							radio.observe('click', function(){
								if(this.checked){
									grid0.checkAll(false);
									radio_sn = sn;
									var rtnList = rec.rtnList || [];
									layout.setDataB(rtnList); <%--[20250217]明細(B區) --%>
								}
							});
							return radio;
						}
					},
					{header:'地號', key:'LAND_NO',
						render:function(rec, val){
							var LAND_NO1 = formatInput.text(rec.LAND_NO1, false);
							var LAND_NO2 = formatInput.text(rec.LAND_NO2, false);
							return LAND_NO1 + " - " + LAND_NO2;
						}
					},
					{header:'使用分區', key:'USE_SECT',
						input:{                                 
							type:'select',  
							opts: USE_SECT_Map
						} 
					},
					{header:'使用地類別', key:'USE_KIND',
						input:{                                 
							type:'select',  
							opts: USE_KIND_Map
						} 
					}
				]
			});

			address3 = new DSZ01000(address_id, "3");

			// 抵押土地座落的縣市別不可變動，所以disable
			var selectObj = address3.getAllSelectObject();
			selectObj.CITY_NAME.disable();

			//--------- 按鈕 ----------
			// 查詢
			$("btn_query").observe('click',function(event){
				buttons.doQuery();
			});

			// 新增
			$('btn_add').observe('click', function(event){
				buttons.doAdd();
			});

			// 刪除
			$('btn_delete').observe('click', function(event){
				buttons.doDelete();
			});

			// 修改
			$('btn_update').observe('click', function(event){
				buttons.doUpdate();
			});

			// 修改地號
			$('btn_update_LAND_NO').observe('click', function(event){
				buttons.doUpdate_LAND_NO();
			});

			// 清除
			$("btn_clear").observe('click',function(event){
				buttons.doClear("1");
			});

			// 取消取件
			$('btn_cancel').observe('click', function(event){
				buttons.doCancel();
			});

			// 土地謄本影像
			$('btn_link1').observe('click', function(event){
				buttons.doLink1();
			});

			// 拆件影像
			$('btn_link2').observe('click', function(event){
				buttons.doLink2();
			});

			<%--[20210311]新增按鈕[銀行件修改]--%>
			$('btn_update_for_bank').observe('click', buttons.doUpdateForBank);
			<%--[20250217]批次選取全選--%>
			$('autoCheckBox_grid0_SelectAll').observe('click', actions.doSelectAllClick );
			<%--[20250306]新增收折土地訊息區塊--%>
			$("A_divB0").observe("click", layout.doShowdiv_B0);

			//--------- 輸入欄位去空白 ----------
			register.textNoSpace('APPLY_ID ID', "upper");

			register.textNoSpace('LAND_NO1 LAND_NO2 LAND_MEASURE ANNOU_YEAR ANNOU_VALUE NAME HOLD_BASE HOLD_UP TRAN_DATE TRAN_VALUE');

			//---------- 載入資料----------
			// 使用者ID
			userId = '${userId}';

			// 角色設定是否為2Q作業人員
			is2Q_PERSON = '${is2Q_PERSON}';

			<%--[20250217]調整土地屬性(使用分區)、土地屬性(使用地類別)下拉選單初始方式--%>
			// 「土地屬性(地目)」下拉選單
			<c:if test="${not empty LAND_POS_List}">
				var LAND_POS_List = ${LAND_POS_List};

				$w('LAND_POS').each(
					function(key){
						selection.createAll(key, LAND_POS_List, "", "", "");
					}
				);
			</c:if>

			buttons.buttonControl("lock");

			if ('${APPLY_ID}' != "") {
				$('APPLY_ID').value = '${APPLY_ID}';
			} else {
				//保留參數管理-取得受理編號
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
			}
			if($('APPLY_ID').value){
				buttons.doQuery();
			}
		}
	};
}

//--------------------------------------------------------------------------
// 註冊事件
//--------------------------------------------------------------------------
var register = {
	// 欄位去空白
	textNoSpace:function (keys, type){
		$w(keys).each(
			function(key){
				$(key).observe('blur', function(event){
					formatInput.text(key);

					if($(key).value){
						if(type == "upper"){
							$(key).value = $(key).value.toUpperCase();
						}else if(type == "lower"){
							$(key).value = $(key).value.toLowerCase();
						}
					}
				});
			}
		);
	},
	// 數字欄位轉換
	isNumber:function (keys){
		$w(keys).each(
			function(key){
				$(key).observe('blur', function(event){
					formatInput.number(key);
				});
			}
		);
	},
	// 金額欄位轉換
	isMoney:function (keys){
		$w(keys).each(
			function(key){
				$(key).observe('blur', function(event){
					formatInput.money(key, true, $(key).pattern);
				});
			}
		);
	}
};

var actions = {		
	doSelectAllClick: function(){
		if(!$('autoCheckBox_grid0_SelectAll').checked){
			return;
		}
		actions.doCheckRadio();		
	},
	doCheckRadio: function(){
		layout.setDataB([]);
		radio_sn = '';
		$$('#grid0 input[type="radio"]').each(function(elem){
			if(elem.checked){
 				elem.checked = false;
 				elem.simulate('click');
 				throw $break;
 			}
		});
	}
};
//--------------------------------------------------------------------------
// 功能按鈕
//--------------------------------------------------------------------------
var buttons = {
	// 按鈕控制
	buttonControl:function(IS_SEPARATE, userId, lockUser){
		var msg = null;
		if(is2Q_PERSON == "Y" && userId && lockUser && userId != lockUser){
			// 判斷若2Q取件人員不一樣,則顯示警示訊息,並且將按鈕disable
			msg = "登入人員不為取件人員，請確認此件取件人員!!";
			$w('btn_add btn_delete btn_update btn_update_LAND_NO btn_cancel').each(
				function(key){
					$(key).disable();
				}
			);
		}else{
			if(is2Q_PERSON == "Y"){
				// 判斷角色為2Q取件人員才可以做退回、取消取件
				$w('btn_cancel').each(
					function(key){
						$(key).enable();
					}
				);
			}else{
				$w('btn_cancel').each(
					function(key){
						$(key).disable();
					}
				);
			}

			$w('btn_add btn_delete btn_update btn_update_LAND_NO').each(
				function(key){
					$(key).enable();
				}
			);
		}
		
		<%--[20210318]SA追加檢核:當APPLY_ID第4碼有”@” -> 銀行件 ->修改按鈕disable，銀行建修改按鈕enable--%>
		<%--[20210323]銀行件判斷條件:受理編號第4碼為“@” AND 受理編號第4,5碼 != “@A” “@B” “@E”--%>
		if(!$('btn_update').disabled) {
			var APPLY_ID = $F('APPLY_ID');
			var btn_update_for_bank = APPLY_ID.substring(3,4) == '@' && !['@A', '@B', '@E'].include(APPLY_ID.substring(3,5));
			if (btn_update_for_bank) {
				$('btn_update_for_bank').disabled = false;
			} else {
				$('btn_update_for_bank').disabled = true;
			}
			if (btn_update_for_bank) {
				$('btn_update').disabled = true;
			} else {
				$('btn_update').disabled = false;
			}
		} else {
			$('btn_update_for_bank').disabled = true;
		}

		// 判斷是否有拆件影像
		if(IS_SEPARATE == "" || IS_SEPARATE == "N"){
			$w('btn_link2').each(
				function(key){
					$(key).disable();
				}
			);
		}else{
			$w('btn_link2').each(
				function(key){
					$(key).enable();
				}
			);
		}

		if(msg){
			alert(msg);
		}
	},
	// 查詢
	doQuery: function(){
		if(!validates.checkInput("query")){
			return;
		}

		//保留參數管理-更新受理編號
		CSRUtil.keepParamsManager.put({'APPLY_ID': $('APPLY_ID').value});
		var queryData = {
			APPLY_ID: $('APPLY_ID').value
		};
		var actionName = "query";
		var params = {"queryData":Object.toJSON(queryData)};
		var successAction = function(resp){
			rtnMap = resp.rtnMap;
			<%--[20250217]新增B0區--%>
			var dataList = resp.dataList || [];
			layout.setDataB0(dataList);
			
			var lockUser = resp.lockUser;
			var IS_SEPARATE;
			if(rtnMap){
				IS_SEPARATE = rtnMap.IS_SEPARATE;
			}
			buttons.buttonControl(IS_SEPARATE, userId, lockUser);
			<%--[20250217]B、C區清空--%>
			layout.setDataB([]);
			<%--[20250306]自動預帶第一筆地號資料--%>
			if(dataList.length>0){
				radio_sn='1';
				layout.doClickRadio();
			}
		};
		var errorAction = function(resp){
			rtnMap = null;
			maxSEQ_NO = "0";
			var rtnList = null;
			var lockUser = null;

			buttons.buttonControl("");
			layout.setDataB0([]);<%--[20250217]新增B0區--%>
			layout.createList([]);
			layout.createDetail(null);
		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 新增
	doAdd:function(){
		if(!validates.checkInput("add")){
			return;
		}

		var A040VO = layout.createA040VO("2");
		A040VO.SEQ_NO = maxSEQ_NO;
		var mapA = layout.createMapA("2");
		if($('OLD_APPLY_ID').innerHTML != $('APPLY_ID').value){
			if(confirm("請確認是否將資料新增到此 "+ $('APPLY_ID').value +" 中?")){
				A040VO.APPLY_ID = $('APPLY_ID').value;
				mapA.APPLY_ID = $('APPLY_ID').value;
			}else{
				return false;
			}
		}

		var actionName = "add";
		var params = {"A040VO":Object.toJSON(A040VO), "mapA":Object.toJSON(mapA)};
		var successAction = function(resp){
			rtnMap = resp.rtnMap;
			<%--[20250217]新增B0區--%>
			var dataList = resp.dataList || [];
			layout.setDataB0(dataList);
			
			var lockUser = resp.lockUser;
			var IS_SEPARATE;
			if(rtnMap){
				IS_SEPARATE = rtnMap.IS_SEPARATE;
			}
			buttons.buttonControl(IS_SEPARATE, userId, lockUser);
			<%--[20250217]B、C區清空--%>
			layout.setDataB([]);
			<%--[20250306]自動預帶第一筆地號資料--%>
			if(dataList.length>0){
				layout.doClickRadio();
			}
		};
		var errorAction = function(resp){

		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 刪除
	doDelete:function(){
		<%--[20250217]需選取資料(單選)後才可刪除資料--%>
		if(radio_sn == ''){
			alert('需選取資料(單選)後才可刪除資料');
			return;
		}
		if($('OLD_APPLY_ID').innerHTML != $('APPLY_ID').value){
			alert("欲刪除的受理編號與原先查詢的資料不同，無法作業!");
			return;
		}
		
		if(!validates.checkInput("delete")){
			return;
		}else if(!confirm("是否確認刪除?")){
			return;
		}

		var A040VO = layout.createA040VO("2");
		var mapA = layout.createMapA("1");

		var actionName = "delete";
		var params = {"A040VO":Object.toJSON(A040VO), "mapA":Object.toJSON(mapA)};
		var successAction = function(resp){
			rtnMap = resp.rtnMap;
			<%--[20250217]新增B0區--%>
			var dataList = resp.dataList || [];
			layout.setDataB0(dataList);
			
			var lockUser = resp.lockUser;
			var IS_SEPARATE;
			if(rtnMap){
				IS_SEPARATE = rtnMap.IS_SEPARATE;
			}
			buttons.buttonControl(IS_SEPARATE, userId, lockUser);
			<%--[20250217]B、C區清空--%>
			layout.setDataB([]);
			<%--[20250306]自動預帶第一筆地號資料--%>
			if(dataList.length>0){
				radio_sn='1';
				layout.doClickRadio();
			}
		};
		var errorAction = function(resp){

		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 修改
	doUpdate:function(){
		if($('OLD_APPLY_ID').innerHTML != $('APPLY_ID').value){
			alert("欲修改的受理編號與原先查詢的資料不同，無法作業!");
			return;
		}
		<%--[20250217]取得更新使用分區與使用地類別，為多選時傳入--%>
		var UPD_USE_LIST = layout.getUPD_USE_LIST(); 
		var mapA = layout.createMapA("3");
		<%--[20250221] 調整判斷單/多選方式--%>
		if(radio_sn != ''){
			<%--[20250217] 單選情況下的判斷方式--%>
			if(!validates.checkInput("update")){
				return;
			}
			if(!validates.compareDataIsSame()){
				return;
			}
			mapA = layout.createMapA("1");
		} else {
			if(UPD_USE_LIST.length == 0){
				alert("需進行單選/批次選取後再進行修改");
				return;
			}
		}
		var A040VO = layout.createA040VO("2");
		
		var actionName = "update";
		var params = {"A040VO":Object.toJSON(A040VO), "mapA":Object.toJSON(mapA), UPD_USE_LIST: Object.toJSON(UPD_USE_LIST), IS_RADIO: radio_sn!='' ? 'Y':'N'};
		var successAction = function(resp){
			rtnMap = resp.rtnMap;
			<%--[20250217]新增B0區--%>
			var dataList = resp.dataList || [];
			layout.setDataB0(dataList);

			var lockUser = resp.lockUser;
			var IS_SEPARATE;
			if(rtnMap){
				IS_SEPARATE = rtnMap.IS_SEPARATE;
			}
			buttons.buttonControl(IS_SEPARATE, userId, lockUser);
			<%--[20250217]B、C區清空--%>
			layout.setDataB([]);
			<%--[20250306]自動預帶第一筆地號資料--%>
			if(dataList.length>0){
				layout.doClickRadio();
			}
		};
		var errorAction = function(resp){

		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 修改地號
	doUpdate_LAND_NO:function(){
	
		if($('OLD_APPLY_ID').innerHTML != $('APPLY_ID').value){
			alert("欲修改的受理編號與原先查詢的資料不同，無法作業!");
			return;
		}
	
		if(!validates.checkInput("update_LAND_NO")){
			return;
		}

		if(oldValue["LAND_NO1"] != $('LAND_NO1').getValue() || oldValue["LAND_NO2"] != $('LAND_NO2').getValue()){
			if(!confirm("請確認要修改的地號資料是否正確")){
				return;
			};
		}else{
			alert("地號沒有更改過，請重新輸入!!");
			return;
		}

		var A040VO = layout.createA040VO("1");

		var mapA = layout.createMapA("1");

		var actionName = "update_LAND_NO";
		var params = {"A040VO":Object.toJSON(A040VO), "mapA":Object.toJSON(mapA)};
		var successAction = function(resp){
			rtnMap = resp.rtnMap;
			<%--[20250217]新增B0區--%>
			var dataList = resp.dataList || [];
			layout.setDataB0(dataList);
			
			var lockUser = resp.lockUser;
			var IS_SEPARATE;
			if(rtnMap){
				IS_SEPARATE = rtnMap.IS_SEPARATE;
			}
			buttons.buttonControl(IS_SEPARATE, userId, lockUser);
			<%--[20250217]B、C區清空--%>
			layout.setDataB([]);
			<%--[20250306]自動預帶第一筆地號資料--%>
			if(dataList.length>0){
				layout.doClickRadio();
			}
		};
		var errorAction = function(resp){

		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 清除
	doClear:function(type){
		layout.clear(type);
		grid.load([]);
		<%--[20250217]新增B0區--%>
		radio_sn = '';
		grid0.load([]);
	},

	// 取消取件
	doCancel:function(){
	
		if($('OLD_APPLY_ID').innerHTML != $('APPLY_ID').value){
			alert("欲取消取件的受理編號與原先查詢的資料不同，無法作業!");
			return;
		}
	
		if(!validates.checkInput("cancel")){
			return;
		}

		var mapA = layout.createMapA("1");

		var actionName = "cancel";
		var params = {"mapA":Object.toJSON(mapA)};
		var successAction = function(resp){

		};
		var errorAction = function(resp){

		};
		ajaxPost(actionName, params, successAction, errorAction);
	},
	// 超連結－土地謄本影像
	doLink1:function(){
		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': $('OLD_APPLY_ID').innerHTML},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});
	},
	// 超連結－拆件影像
	doLink2:function(){
		popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
			'parameters': {'APPLY_ID': rtnMap.IS_SEPARATE},
			'fullScreen': false,
			'attributes': {'resizable': 'yes'}
		});
	},
	doUpdateForBank: function(){<%--[20210311] 銀行件修改--%>
		if($('OLD_APPLY_ID').innerHTML != $('APPLY_ID').value){
			alert("欲取消取件的受理編號與原先查詢的資料不同，無法作業!");
			return;
		}
		<%--[20250217]取得更新使用分區與使用地類別，為多選時傳入--%>
		var UPD_USE_LIST = layout.getUPD_USE_LIST(); 
		var mapA = layout.createMapA("3");
		<%--[20250221] 調整判斷單/多選方式--%>
		if(radio_sn != ''){
			<%--[20210311]僅可修改移轉年月、前次移轉現值、使用分區，需檢核其他欄位不可修改--%>
			<%--[20210323]需求變更:銀行件修改僅能修改使用分區--%>
			<%--[20210421]配合銀行件難字問題不卡控土地坐落，所有權人--%>
			<%--[20250217] 單選情況下的判斷方式--%>
			var fixedField = $('areaB').select('input', 'select').filter(function(it){
				it.removeClassName('m_validator-failed');
				return  !it.name == "NAME" && !it.name.include("DSZ01000") && !['USE_SECT'].include(it.name) && recordForCheckFast[it.name] != it.value;
			});
			
			if (fixedField.length > 0) {
				fixedField.forEach(function(it) {
					it.addClassName('m_validator-failed');
				});
				alert('僅可修改使用分區');
			}
			
			if(!validates.checkInput("updateForBank")){
				return;
			}
			mapA = layout.createMapA("1");
		} else {
			if(UPD_USE_LIST.length == 0){
				alert("需進行單選/批次選取後再進行修改");
				return;
			}
		}
		var A040VO = layout.createA040VO("2");

		var actionName = "updateForBank";
		var params = {"A040vo":Object.toJSON(A040VO), "mapA":Object.toJSON(mapA), UPD_USE_LIST: Object.toJSON(UPD_USE_LIST), IS_RADIO: radio_sn!='' ? 'Y':'N'};
		var successAction = function(resp){
			rtnMap = resp.rtnMap;
			<%--[20250217]新增B0區--%>
			var dataList = resp.dataList || [];
			layout.setDataB0(dataList);
			
			var lockUser = resp.lockUser;
			var IS_SEPARATE;
			if(rtnMap){
				IS_SEPARATE = rtnMap.IS_SEPARATE;
			}
			buttons.buttonControl(IS_SEPARATE, userId, lockUser);

			<%--[20250217]B、C區清空--%>
			layout.setDataB([]);
			<%--[20250306]自動預帶第一筆地號資料--%>
			if(dataList.length>0){
				layout.doClickRadio();
			}
		};
		var errorAction = function(resp){

		};
		ajaxPost(actionName, params, successAction, errorAction);
		
	}
};

//--------------------------------------------------------------------------
// 檢核
//--------------------------------------------------------------------------
var keyNM = {
	"LAND_NO1":"地號(一)",
	"LAND_NO2":"地號(二)",
	"LAND_MEASURE":"土地面積",
	"ANNOU_YEAR":"最新公告年度",
	"ANNOU_VALUE":"公告現值",
	"NAME":"所有權人",
	"ID":"所有權人ID",
	//"BIRTHDAY":"所有權人生日",
	"HOLD_BASE":"持分(分母)",
	"HOLD_UP":"持分(分子)",
	"TRAN_DATE":"移轉年月",
	"TRAN_VALUE":"前次移轉現值"
};
keyNM[address_id + "_CITY_NAME"] = "抵押土地座落(市)";
keyNM[address_id + "_TOWN_NAME"] = "抵押土地座落(鄉鎮市區)";
keyNM[address_id + "_LAND_NAME1"] = "抵押土地座落(段)";
keyNM[address_id + "_LAND_NAME2"] = "抵押土地座落(小段)";

var validates = {
	// 畫面欄位
	checkInput: function(type){
		$$('#form1 input[type="text"]').each(
			function(text){
				text.style.backgroundColor = '';
			}
		);
		
		$('areaB').select('input', 'select').forEach(function(it){
			it.removeClassName('m_validator-failed');
		});

		validator.clear();

		if(type == "query"){
			if($('APPLY_ID').value == ""){
				validator.define("APPLY_ID", "", "您必須填入受理編號的資料!!", validates.returnFalse);
			}
		}else if(type == "add" || type == "update" || type == "updateForBank"){
		
			if($('APPLY_ID').value == ""){
				validator.define("APPLY_ID", "", "您必須填入受理編號的資料!!", validates.returnFalse);
			}
		
			if($('OLD_APPLY_ID').innerHTML == ""){
				validator.define('APPLY_ID', "", "請先查詢土地謄本", validates.returnFalse);
			}

			if(type == "updateForBank"){
				//不檢核所有權人中文
			} else {
				$w('NAME').each(
					function(key){
						if($(key).value == ""){
							validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
						}else if(validation.hasHalfType($(key).value)){
							validator.define(key, "", keyNM[key] + "不可輸入半形字", validates.returnFalse);
						}
					}
				);
			}

			// 土地座落下拉選單
			$w('_CITY_NAME _TOWN_NAME _LAND_NAME1').each(
				function(key){
					key = address_id + key;
					if($(key).length > 1 && $(key).selectedIndex === 0){
						validator.define(key, "", "請選擇一筆" + keyNM[key], validates.returnFalse);
					}
				}
			);

			// 地號
			$w('LAND_NO1 LAND_NO2').each(
				function(key){
					var value = $(key).value;
					if(value == ""){
						validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
					}else if(!validates.checkedNum(key)){
						validator.define(key, "", keyNM[key] + "只能輸入數字", validates.returnFalse);
					}else if(key == "LAND_NO1" || key == "LAND_NO2"){
						var length = value.length;
						var maxLength = 4;
						var new_LAND_NO = "";
						for(var i = length; i < maxLength; i++){
							new_LAND_NO = new_LAND_NO + "0";
						}
						$(key).value = new_LAND_NO + value;
					}
				}
			);

			// 數字
			var HOLD_BASE;
			var HOLD_UP;
			$w('LAND_MEASURE ANNOU_YEAR ANNOU_VALUE HOLD_BASE HOLD_UP TRAN_VALUE').each(
				function(key){
					if($(key).value.length == 0){
						validator.define(key, "", keyNM[key] + "為必要欄位", validates.returnFalse);
					}else if(!validates.checkNumPattern(key)){
						var intLength = $(key).intLength;
						var decLength = $(key).decLength;

						var msg;
						if(intLength && decLength){
							msg = keyNM[key] + "格式有誤(應為整數" + intLength + "位、小數" + decLength + "位)";
						}else if(intLength){
							msg = keyNM[key] + "格式有誤(應為整數" + intLength + "位)";
						}

						validator.define(key, "", msg, validates.returnFalse);
					}else if(key == "HOLD_BASE"){
						HOLD_BASE = $(key).getValue();
					}else if(key == "HOLD_UP"){
						HOLD_UP = $(key).getValue();
					}
				}
			);

			// 「持分(分母)」不可小於「持分(分子)」
			HOLD_BASE = parseInt(HOLD_BASE, 10);
			HOLD_UP = parseInt(HOLD_UP, 10);
			if(HOLD_BASE && HOLD_UP){
				if(HOLD_BASE < HOLD_UP){
					validator.define("HOLD_BASE", "", "分母不可小於分子!", validates.returnFalse);
				}
			}

			// ID
			//問題單編號 20200320-0119 BY余凱鈞
			//214@L090033和094@L091407因所有權人為外國人，鑑價員於土地謄本輸入畫面更新使用分區時，會被檢核ID不符合身分證字號或統一編號
			//，故無法修正。但若使用分區為空值，後續鑑價呈核亦會被檢核卡住。
			//因鑑價員需修改使用分區，而土地謄本畫面修改時會檢核所有權人ID，導致被檢核又無法修改。
			//與鑑價企劃科怡文確認，若為銀行件需修改使用分區就不檢核ID格式
			if(type == "update" && $('OLD_APPLY_ID').innerHTML.indexOf("@")>=0 ){
				$w('ID').each(
					function(key){
						var value = $(key).value;
						if(value == ""){
							validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
						}						
					}
				);	
				
			} else if(type == "updateForBank" && $('OLD_APPLY_ID').innerHTML.indexOf("@")>=0 ){
				$w('ID').each(
						function(key){
							var value = $(key).value;
							if(value == ""){
								validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
							}						
						}
					);
			
			} else {			
				$w('ID').each(
					function(key){
						var value = $(key).value;
						if(value == ""){
							validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
						}else if(value.length!=10 && value.length!=8){
							validator.define(key, "", keyNM[key] + "需為8碼統編或10碼身份證號", validates.returnFalse);
						}else if(value.length==10 && !idCheck1(value)){
							validator.define(key, "", keyNM[key] + "不合法(須為有效ID)", validates.returnFalse);
						}else if(value.length==8 && !validation.checkUniSN(value)){
							validator.define(key, "", keyNM[key] + "不合法統一編號", validates.returnFalse);
						}
						
					}
				);
			}

			// 移轉年月
			$w('TRAN_DATE').each(
				function(key){
					var value = $(key).value;
					if(value == ""){
						validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
					}else{
						if(key == "TRAN_DATE"){
							if(value && (value.length == 4 || value.length == 5)){
								value = value + "01";
							}
						}

						if(value == ""){
							validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
						}else if(!validates.checkDate(value, "false", "ROC")){
							validator.define(key, "", keyNM[key] + "格式錯誤", validates.returnFalse);
						}
					}
				}
			);
		}else if(type == "delete" || type == "cancel" || type == "reject"){
			if($('OLD_APPLY_ID').innerHTML == ""){
				validator.define('APPLY_ID', "", "請先查詢土地謄本", validates.returnFalse);
			}
		}else if(type == "update_LAND_NO"){
			if($('OLD_APPLY_ID').innerHTML == ""){
				validator.define('APPLY_ID', "", "請先查詢土地謄本", validates.returnFalse);
			}

			// 地號
			$w('LAND_NO1 LAND_NO2').each(
				function(key){
					var value = $(key).value;
					if(value == ""){
						validator.define(key, "", keyNM[key] + "不可為空", validates.returnFalse);
					}else if(!validates.checkedNum(key)){
						validator.define(key, "", keyNM[key] + "只能輸入數字", validates.returnFalse);
					}else if(key == "LAND_NO1" || key == "LAND_NO2"){
						var length = value.length;
						var maxLength = 4;
						var new_LAND_NO = "";
						for(var i = length; i < maxLength; i++){
							new_LAND_NO = new_LAND_NO + "0";
						}
						$(key).value = new_LAND_NO + value;
					}
				}
			);
		}

		return validator.validate();
	},
	// 檢查輸入日期是否合法
	checkDate:function(date, checkEmpty, mod){
		var inputDate;
		if($(date)){
			inputDate = $(date).value;
		}else{
			inputDate = date;
		}

		if(checkEmpty != "true" && inputDate == ""){
			return true;
		}else{
			if(mod == "ROC"){
				return isROCdate(inputDate, false);
			}else{
				return isADdate(inputDate,false);
			}
		}
	},
	// 檢核傳進來的值是否為正確的數字格式？是，則將該欄位依照pattern(自訂或預設)格式化；否，則將該欄位清空
	checkedNum:function(key){
		var value = $(key).getValue().trim();

		if(isNaN(parseInt(value))){
			return false;
		}else{
			return true;
		}
	},
	// 檢核數字欄位是否符合規定的長度
	checkNumPattern:function(key, isPositive){
		if(validates.checkedNum(key)){
			var intLength = $(key).intLength;
			var decLength = $(key).decLength ? $(key).decLength : 0;

			if(!isNaN(parseInt(intLength, 10)) && !isNaN(parseInt(decLength, 10))){
				var value = $(key).getValue();

				var tmp1 = value.split(".");
				var INT = tmp1[0];
				var DEC = (tmp1.length > 1) ? tmp1[1] : "";

				if(isPositive === true){
					if(INT < 0){
						return false;
					}else if(INT.length > intLength){
						return false;
					}
				}else if(isPositive === false){
					if(INT >= 0){
						return false;
					}else if(INT.length > intLength++){
						return false;
					}
				}else{
					if(INT < 0 && INT.length > intLength){
						return false;
					}else if(INT >= 0 && INT.length > intLength++){
						return false;
					}
				}

				if(DEC.length > decLength){
					return false;
				}else{
					return true;
				}
			}else{
				return true;
			}
		}else{
			return false;
		}
	},
	// 比較欲修改資料與原資料是否相同
	compareDataIsSame: function(){
		var updateColumn = "";
		if(oldValue["CITY_NAME"] != address3.getCITY_NAME()){
			updateColumn = updateColumn + keyNM[address_id + "_CITY_NAME"] + "、";
		}

		if(oldValue["LOCATION1"] != address3.getTOWN_NAME()){
			updateColumn = updateColumn + keyNM[address_id + "_TOWN_NAME"] + "、";
		}

		if(oldValue["LOCATION2"] != address3.getLAND_NAME1()){
			updateColumn = updateColumn + keyNM[address_id + "_LAND_NAME1"] + "、";
		}

		if(oldValue["LOCATION3"] != address3.getLAND_NAME2()){
			updateColumn = updateColumn + keyNM[address_id + "_LAND_NAME2"] + "、";
		}

		if(oldValue["LAND_NO1"] != $('LAND_NO1').getValue()){
			updateColumn = updateColumn + keyNM["LAND_NO1"] + "、";
		}

		if(oldValue["LAND_NO2"] != $('LAND_NO2').getValue()){
			updateColumn = updateColumn + keyNM["LAND_NO2"] + "、";
		}

		if(oldValue["NAME"] != $('NAME').getValue()){
			updateColumn = updateColumn + keyNM["NAME"] + "、";
		}

		if(oldValue["ID"] != $('ID').getValue()){
			updateColumn = updateColumn + keyNM["ID"] + "、";
		}

		//if(oldValue["BIRTHDAY"] != $('BIRTHDAY').getValue()){
		//	updateColumn = updateColumn + keyNM["BIRTHDAY"] + "、";
		//}


		if(updateColumn != ""){
			var length = updateColumn.length;
			updateColumn = updateColumn.substring(0, length-1);

			return confirm("確定要修改【" + updateColumn + "】的資料嗎？");
		}else{
			return true;
		}
	},
	// 回傳false
	returnFalse:function(){
		return false;
	}
};

//--------------------------------------------------------------------------
// 畫面操作
//--------------------------------------------------------------------------
var layout = {
	<%--[20250217]B0區 --%>
	setDataB0: function(rtnList){
		grid0.load(rtnList);
	},
	<%--[20250217]明細(B區) --%>
	setDataB: function(rtnList){	
		layout.createList(rtnList);
		if(rtnList && rtnList.length > 0){
			maxSEQ_NO = rtnList[rtnList.length-1].SEQ_NO;
		}else{
			record = null;
			layout.createDetail();
			maxSEQ_NO = "0";
		}
	},
	<%--[20250217]多選時傳入 --%>
	getUPD_USE_LIST: function(){
		var UPD_USE_LIST = [];
		var dataList = [];
		<%--[20250221] 調整單/多選取得更新清單方式--%>
		if(radio_sn==''){<%--多選，直接取得該筆資料的rtnList--%>
			UPD_USE_LIST = grid0.getCheckedRecords();
			UPD_USE_LIST.each(function(rec){
				var rtnList = rec.rtnList || [];
				rtnList.each(function(data){ <%--僅修改使用分區與使用地類別--%>
					data.USE_SECT = rec.USE_SECT;
					data.USE_KIND = rec.USE_KIND;
					dataList.push(data);
				});
			});
		} else {<%--單選，取得B區所有資料--%>
			UPD_USE_LIST = grid.getAllRecords();
			UPD_USE_LIST.each(function(rec){<%--排除掉當前資料序號後，其他同地號僅修改使用分區與使用地類別--%>
				if(SECT_SEQ_NO!=rec.SEQ_NO){
					rec.USE_SECT = $('autoInput_USE_SECT_'+radio_sn).getValue() || '';
					rec.USE_KIND = $('autoInput_USE_KIND_'+radio_sn).getValue() || '';	
					dataList.push(rec);
				}
			});
		}
		return dataList;
	},
	// 產生list
	createList:function(records){
		grid.load(records);
	},
	// 產生明細
	createDetail:function(){
		layout.clear();

		oldValue = {};

		if(rtnMap){
			var apply_id = formatInput.text(rtnMap.APPLY_ID, false);
			$('OLD_APPLY_ID').innerHTML = apply_id;
			oldValue["APPLY_ID"] = apply_id;

			var apply_process_Name = formatInput.text(rtnMap.APPLY_PROCESS_NM, false);
			$('APPLY_PROCESS_NM').innerHTML = apply_process_Name;
			oldValue["APPLY_PROCESS_NM"] = apply_process_Name;

			var cityName = formatInput.text(rtnMap.CITY, false);
			address3.setCITY_NAME(cityName);

			oldValue["CITY_NAME"] = cityName;
		}


		if(record){
			var townName = formatInput.text(record.LOCATION1, false);
			address3.setTOWN_NAME(townName);
			oldValue["LOCATION1"] = townName;

			var townName = formatInput.text(record.LOCATION1, false);
			address3.setTOWN_NAME(townName);
			oldValue["LOCATION1"] = townName;

			var landName1 = formatInput.text(record.LOCATION2, false);
			address3.setLAND_NAME1(landName1);
			oldValue["LOCATION2"] = landName1;

			var landName2 = formatInput.text(record.LOCATION3, false);
			address3.setLAND_NAME2(formatInput.text(record.LOCATION3, false));
			oldValue["LOCATION3"] = landName2;

			var land_no1 = formatInput.text(record.LAND_NO1, false);
			$('LAND_NO1').value = land_no1;
			oldValue["LAND_NO1"] = land_no1;

			var land_no2 = formatInput.text(record.LAND_NO2, false);
			$('LAND_NO2').value = land_no2;
			oldValue["LAND_NO2"] = land_no2;

			var land_measure = formatInput.money(record.LAND_MEASURE, false);
			$('LAND_MEASURE').value = land_measure;
			oldValue["LAND_MEASURE"] = land_measure;

			var annou_year = formatInput.money(record.ANNOU_YEAR, false);
			$('ANNOU_YEAR').value = annou_year;
			oldValue["ANNOU_YEAR"] = annou_year;

			var annou_value = formatInput.money(record.ANNOU_VALUE, false);
			$('ANNOU_VALUE').value = annou_value;
			oldValue["ANNOU_VALUE"] = annou_value;

			var name = formatInput.text(record.NAME, false);
			$('NAME').value = name;
			oldValue["NAME"] = name;

			var id = formatInput.text(record.ID, false);
			$('ID').value = id;
			oldValue["ID"] = id;

			//var birthday = formatInput.Y2KDate2ROCDate(record.BIRTHDAY);
			//$('BIRTHDAY').value = birthday;
			//oldValue["BIRTHDAY"] = birthday;		
			var birthday = formatInput.Y2KDate2ROCDate(record.BIRTHDAY, "/");
			$('BIRTHDAY').innerHTML = birthday;
			oldValue["BIRTHDAY"] = birthday;

			var hold_base = formatInput.money(record.HOLD_BASE, false);
			$('HOLD_BASE').value = hold_base;
			oldValue["HOLD_BASE"] = hold_base;

			var hold_up = formatInput.money(record.HOLD_UP, false);
			$('HOLD_UP').value = hold_up;
			oldValue["HOLD_UP"] = hold_up;

			var tran_date = formatInput.Y2KMonth2ROCMonth(record.TRAN_DATE);
			$('TRAN_DATE').value = tran_date;
			oldValue["TRAN_DATE"] = tran_date;

			var tran_value = formatInput.money(record.TRAN_VALUE, false);
			$('TRAN_VALUE').value = tran_value;
			oldValue["TRAN_VALUE"] = tran_value;
			
			var use_sect = formatInput.text(record.USE_SECT, false);
			$('USE_SECT').value = use_sect;
			oldValue["USE_SECT"] = use_sect;

			var use_kind = formatInput.text(record.USE_KIND, false);
			$('USE_KIND').value = use_kind;
			oldValue["USE_KIND"] = use_kind;

			var land_pos = formatInput.text(record.LAND_POS, false);
			$('LAND_POS').value = land_pos;
			oldValue["LAND_POS"] = land_pos;

			var input_id = formatInput.text(record.INPUT_ID, false);
			$('INPUT_ID').innerHTML = input_id;
			oldValue["INPUT_ID"] = input_id;

			var input_nm = formatInput.text(record.INPUT_NM, false);
			$('INPUT_NM').innerHTML = input_nm;
			oldValue["INPUT_NM"] = input_nm;

			var input_date = formatInput.Y2KDate2ROCDate(record.INPUT_DATE, "/");
			$('INPUT_DATE').innerHTML = input_date;
			oldValue["INPUT_DATE"] = input_date;
			<%--[20250221]單選換頁時紀錄當前資料序號--%>
			SECT_SEQ_NO = record.SEQ_NO;
		}
		
		<%--[20210311]將可輸入欄位放入recordForCheckFast物件，方便快速檢核資料異動--%>
		<%--[20210421]配合銀行件難字問題不卡控土地坐落，所有權人--%>
		$('areaB').select('input', 'select').forEach(function(it){
			if(!it.id.include("DSZ01000") || it.id == "NAME"){
				recordForCheckFast[it.name] = it.value;
			}
		});
		
	},
	// 清除畫面欄位
	clear:function(type){
		$$('#form1 input[type="text"]').each(
			function(text){
				// 執行清除
				if(type == "1"){
					text.value = "";
				}else if(text.id != "APPLY_ID"){
					text.value = "";
				}
			}
		);
		
		/*
		$$('.contentsTd span').each(
			function(span){
				if(span.innerHTML.indexOf("第") <= 0){
					span.innerHTML = '';
				}
			}
		);
		*/
		$w('USE_SECT USE_KIND LAND_POS').each(
			function(key){
				$(key).options[0].selected = true;
			}
		);

		address3.setCITY_NAME("");
	},
	// 畫面資料(C區)存成A040_VO
	createA040VO: function(type){
		var A040VO = {};

		// 異動前的資料(只有修改地號會用到)
		if(type == "1"){
			if(record){
				var dataKey = Object.keys(record);
				dataKey.each(
					function(key){
						A040VO[key] = record[key];
					}
				);
				A040VO.LAND_NO1 = $('LAND_NO1').getValue();
				A040VO.LAND_NO2 = $('LAND_NO2').getValue();
			}
		}
		// 異動後的資料
		else if(type == "2"){
			if(rtnMap){
				A040VO['APPLY_ID'] = rtnMap.APPLY_ID;
				A040VO['APPLY_PROCESS_NM'] = rtnMap.APPLY_PROCESS_NM;
				A040VO['CITY'] = address3.getCITY_NAME();
				A040VO['LOCATION1'] = address3.getTOWN_NAME();
				A040VO['LOCATION2'] = address3.getLAND_NAME1();
				A040VO['LOCATION3'] = address3.getLAND_NAME2();
				A040VO['LAND_NO1'] = $('LAND_NO1').getValue();
				A040VO['LAND_NO2'] = $('LAND_NO2').getValue();
				A040VO['LAND_MEASURE'] = $('LAND_MEASURE').getValue();
				A040VO['ANNOU_YEAR'] = $('ANNOU_YEAR').getValue();
				A040VO['ANNOU_VALUE'] = $('ANNOU_VALUE').getValue();
				A040VO['NAME'] = $('NAME').getValue();
				A040VO['ID'] = $('ID').getValue();
				//A040VO['BIRTHDAY'] = formatInput.ROCDate2Y2KDate($('BIRTHDAY').getValue());
				A040VO['BIRTHDAY'] = (record) ? record.BIRTHDAY : null;
				A040VO['HOLD_BASE'] = $('HOLD_BASE').getValue();
				A040VO['HOLD_UP'] = $('HOLD_UP').getValue();
				A040VO['TRAN_DATE'] = formatInput.ROCDate2Y2KDate($('TRAN_DATE').getValue() + "01");
				A040VO['TRAN_VALUE'] = $('TRAN_VALUE').getValue();
				<%--[20250217]使用分區與使用地類別，單選時資料從B0區取得; 新增給空值--%>
				A040VO['USE_SECT'] = (radio_sn!='') ? $('autoInput_USE_SECT_'+radio_sn).getValue() : '0';
				A040VO['USE_KIND'] = (radio_sn!='') ? $('autoInput_USE_KIND_'+radio_sn).getValue() : '0';
				A040VO['LAND_POS'] = $('LAND_POS').getValue();
				A040VO['INPUT_ID'] = (record) ? record.INPUT_ID : "";
				A040VO['INPUT_DATE'] = (record) ? record.INPUT_DATE : null;
				A040VO['APPLY_PROCESS'] = rtnMap.APPLY_PROCESS;
				A040VO['CAPT_DATE'] = rtnMap.CAPT_DATE;
				A040VO['CRED_ID'] = rtnMap.CRED_ID;
				A040VO['SEQ_NO'] = (record) ? record.SEQ_NO : "0";
			} 
		}
		return A040VO;
	},
	// rtnMap存成MapA
	createMapA: function(type){
		var mapA = {};

		// 異動前的資料
		if(type == "1"){
			if(rtnMap && record){
				mapA["APPLY_ID"] = rtnMap.APPLY_ID;
				mapA["APPLY_PROCESS"] = rtnMap.APPLY_PROCESS;
				mapA["CRED_ID"] = rtnMap.CRED_ID;
				mapA["CAPT_DATE"] = rtnMap.CAPT_DATE;
				mapA["LAND_NO1"] = record.LAND_NO1;
				mapA["LAND_NO2"] = record.LAND_NO2;
				mapA["ID"] = record.ID;
				mapA["TRAN_DATE"] = record.TRAN_DATE;
				mapA["INPUT_ID"] = record.INPUT_ID;
				mapA["2Q_PERSON"] = is2Q_PERSON;
			}
		}
		// 異動後的資料
		else if(type == "2"){
			if(rtnMap){
				mapA["APPLY_ID"] = rtnMap.APPLY_ID;
				mapA["APPLY_PROCESS"] = rtnMap.APPLY_PROCESS;
				mapA["CRED_ID"] = rtnMap.CRED_ID;
				mapA["CAPT_DATE"] = rtnMap.CAPT_DATE;
				mapA["LAND_NO1"] = $('LAND_NO1').getValue();
				mapA["LAND_NO2"] = $('LAND_NO2').getValue();
				mapA["ID"] = $('ID').getValue();
				mapA["TRAN_DATE"] = formatInput.ROCDate2Y2KDate($('TRAN_DATE').getValue() + "01");
				mapA["INPUT_ID"] = (record) ? record.INPUT_ID : "";
				mapA["2Q_PERSON"] = is2Q_PERSON;
			}
		} else if(type == "3"){ <%--[20250217] 多選傳入受編與進度--%>
			if(rtnMap){
				mapA['APPLY_ID'] = rtnMap.APPLY_ID;
				mapA['APPLY_PROCESS'] = rtnMap.APPLY_PROCESS;
				mapA["2Q_PERSON"] = is2Q_PERSON;
			}
		}
		return mapA;
	},
	doShowdiv_B0 : function(){ <%--[20250306]新增收折土地訊息區塊--%>
		if($('div_B0').style.display != 'none'){
			$('div_B0').style.display = 'none';
		}else{
			$('div_B0').style.display = 'block';
		}
	},
	doClickRadio : function(){
		<%--[20250306]自動預帶第一筆地號資料--%>
		if(''==radio_sn){
			radio_sn='1';
		}
		var page = Math.ceil(radio_sn/10);
		grid0.pageCtrl.loadPage(page);
		$('grid0_radio'+radio_sn).click();
	}
};

//--------------------------------------------------------------------------
// 下拉選單操作
//--------------------------------------------------------------------------
var selection = {
	// 依照傳入資料與id，產生下拉選單
	createAll:function(tagID, optionList, initialText, choiceValue, isCode_CodeNM, key, value){
		if(!key){
			key = "CODE";
		}
		if(!value){
			value = "CODE_NM";
		}

		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionList){
				for(var i = 0; i < optionList.length; i++){
					if(isCode_CodeNM){
						selection.create(tagID, optionList[i][key], optionList[i][key] + " " + optionList[i][value], choiceValue);
					}else{
						selection.create(tagID, optionList[i][key], optionList[i][value], choiceValue);
					}
				}
			}
		}
	},
	// 依照傳入資料與id，產生下拉選單(資料為Map)
	createAll4Map:function(tagID, optionMap, initialText, choiceValue, isCode_CodeNM){
		var target = $(tagID);
		if(target){
			if(initialText){
				selection.create(tagID, "", initialText, "");
			}
			if(optionMap){
				var dataKey = Object.keys(optionMap);
				dataKey.each(
					function(key){
						if(isCode_CodeNM){
							selection.create(tagID, key, key + " " + optionMap[key], choiceValue);
						}else{
							selection.create(tagID, key, optionMap[key], choiceValue);
						}
					}
				);
			}
		}
	},
	// 產生單一下拉選單(如果下拉選單的value == 資料的Value，則將該option選擇起來)
	create:function(tagID, optionValue, optionText, choiceValue){
		$(tagID).options.add(new Option(optionText, optionValue));

		if(choiceValue && optionValue == choiceValue){
			$(tagID).options[$(tagID).length - 1].selected = true;
		}
	},
	// 清空下拉選單
	clean:function(tagID){
		$(tagID).options.length = 0;
	}
};

//--------------------------------------------------------------------------
// 格式化
//--------------------------------------------------------------------------
var formatInput = {
	// 一般輸入
	text:function(key_Value, isKey, defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		if(!defaultVaule && defaultVaule != "0"){
			defaultVaule = "";
		}

		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}

		// 處理value
		if(value || !isNaN(parseInt(value))){
			value = value + "";
		}else {
			value = defaultVaule + "";
		}

		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 數字輸入
	number:function(key_Value, isKey,  defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		if(isNaN(parseInt(defaultVaule))){
			defaultVaule = "";
		}

		// 取得value
		var value;
		if(isKey){
			value = $(key_Value).value;
		}else{
			value = key_Value;
		}

		// 處理value
		if(isNaN(parseInt(value))){
			value = defaultVaule + "";
		}else {
			value = value + "";
		}

		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 金額輸入
	money:function(key_Value, isKey, pattern, mode, defaultVaule){
		if(isKey === null || isKey === undefined || isKey === ""){
			if($(key_Value)){
				isKey = true;
			}else{
				isKey = false;
			}
		}else if(!key_Value || !$(key_Value)){
			isKey = false;
		}

		if(isNaN(parseInt(defaultVaule))){
			defaultVaule = "";
		}

		// mode={0:四捨五入, 1:只做格式化(無條件捨去), 2:無條件進位}
		if(pattern){
		}else{
			pattern = pattern_money2;
		}

		if(mode){
		}else{
			mode = "0";
		}

		var value;
		if(isKey){
			value = $(key_Value).getValue().trim();
			pattern = ($(key_Value).pattern) ? $(key_Value).pattern : pattern;
		}else{
			value = key_Value;
		}

		var scale = pattern.split(".");
		var length = scale.length;
		if(length > 1){
			scale = scale[length-1].length;
		}else{
			scale = 0;
		}

		// 處理value
		if(isNaN(parseInt(value))){
			value = defaultVaule.trim();
		}else {
			var bigNum = new BigNumber(value, scale).toString();
			if(value === 0){
				return "0";
			}else if(mode == "0"){
				value = CSRUtil.$fmt(bigNum, pattern);
			}else if(mode == "1"){
				if(scale == "0"){
					value = CSRUtil.$fmt(bigNum, pattern, "true");
				}else{
					value = CSRUtil.$fmt(bigNum, pattern);
				}
			}else if(mode=="2"){

			}
		}

		// 設定或回傳value
		if(isKey){
			$(key_Value).value = value.trim();
		}else{
			return value.trim();
		}
	},
	// 取得金額位數(台幣：整數、非台幣：兩位小數)
	getMoneyPattern:function(CURR){
		if(CURR == "NTD"){
			return pattern_money;
		}else{
			return pattern_money2;
		}
	},
	// 民國年轉西元年
	ROCDate2Y2KDate:function(date){
		var rocDate;
		var isKey;
		if(date && $(date)){
			rocDate = $(date).value;
			isKey = true;
		}else{
			rocDate = date;
			isKey = false;
		}

		if(rocDate){
			var dateLength = rocDate.length;

			if(dateLength == 5 && isROCdate("0" + rocDate, false)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);

				if($(date)){
					$(date).value = value;
				}

				return value;
			}else if(dateLength > 5 && isROCdate(rocDate, false)){
				var value = (parseInt(rocDate.substring(0, dateLength-4), 10)+1911) + "-" + rocDate.substring(dateLength-4, dateLength-2) + "-" + rocDate.substring(dateLength-2);

				if($(date)){
					$(date).value = value;
				}

				return value;
			}
		}

		if(isKey){
			alert("輸入的日期：" + rocDate + "，不符合民國年格式(例：1000101)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年轉民國年
	Y2KDate2ROCDate:function(date, symbol){
		var y2kDate;
		var isKey;
		if(date && $(date)){
			y2kDate = $(date).value;
			isKey = true;
		}else{
			y2kDate = date;
			isKey = false;
		}

		if(!symbol){
			symbol = "";
		}

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";
			if(isADdate(y2kDate,false)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1] + symbol + dates[2];

				if(splitTool.length > 1){
					y2kDate = y2kDate + " " + splitTool[1];
				}

				if($(date)){
					$(date).value = y2kDate;
				}

				return y2kDate;
			}
		}

		if(isKey){
			alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
			$(date).value = "";
		}
		return "";
	},
	// 西元年月轉民國年月
	Y2KMonth2ROCMonth:function(date, symbol){
		var y2kDate;
		var isKey;
		if(date && $(date)){
			y2kDate = $(date).value;
			isKey = true;
		}else{
			y2kDate = date;
			isKey = false;
		}

		if(!symbol){
			symbol = "";
		}

		if(y2kDate){
			var splitTool = y2kDate.split(" ");
			y2kDate = (splitTool[0]) ? splitTool[0] : "";

			if(y2kDate.length < 10){
				y2kDate = y2kDate + "-01";
			}
			if(isADdate(y2kDate,false)){
				var dates = y2kDate.split("-");
				var rocYear = parseInt(dates[0], 10)-1911;
				if(rocYear.length < 2){
					rocYear = "0" + rocYear;
				}
				y2kDate = rocYear + symbol + dates[1];

				if($(date)){
					$(date).value = y2kDate;
				}

				return y2kDate;
			}
		}

		if(isKey){
			alert("輸入的日期：" + y2kDate + "，不符合西元年格式(例：2011-01-01)");
			$(date).value = "";
		}
		return "";
	}
};

//--------------------------------------------------------------------------
// 超連結
//--------------------------------------------------------------------------
var hyperlinks = {
	// popUp
	popup:function(conf, callbackFun){
		popupWin.callbackHandler = callbackFun;
		popupWin.popup(conf);
	},
	// fullPopUp
	fullpopup:function(url, text){
		if(url){
			if(text){
				return popupWin.createFullPopupLink(text, url);
			}else{
				popupWin.fullPopup(url);
			}
		}
	},
	// 開新視窗
	openwindow:function(url, title, attrs){
		if(url){
			if(attrs){
				window.open(url, title, attrs);
			}else{
				window.open(url);
			}
		}
	}
};

//--------------------------------------------------------------------------
// 共用－Ajax
//--------------------------------------------------------------------------
function ajaxPost( actionName, params, successAction, errorAction){
   	new Ajax.Request(
		"<%=dispatcher%>/DSA1_0400/" + actionName,
		{ parameters: params,
          onSuccess: function(response) {
			var resp = response.responseJSON;

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

//-->
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<form id="form1" name="form1" method="post">

<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="areaA">
	<tr>
		<td class="tbYellow" width="15%">
			受理編號
		</td>
		<td class="tbYellow2">
			<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" value="">
			<input id="btn_query" name="btn_query" type="button" class="button" value="查詢">
			<input id="btn_link1" name="btn_link1" type="button" class="button" value="土地謄本影像">
			<input id="btn_link2" name="btn_link2" type="button" class="button" value="拆件影像">
		</td>
	</tr>
	<tr>
		<td align="center" colspan="2">
			<input id="btn_add" name="btn_add" type="button" class="button" value="新增">
			<input id="btn_delete" name="btn_delete" type="button" class="button" value="刪除">
			<input id="btn_update" name="btn_update" type="button" class="button" value="修改">
			<input id="btn_update_LAND_NO" name="btn_update_LAND_NO" type="button" class="button" value="修改地號">
			<input id="btn_clear" name="btn_clear" type="button" class="button" value="清除">
			<input id="btn_cancel" name="btn_cancel" type="button" class="button" value="取消取件">
			<input id="btn_update_for_bank" name="btn_update_for_bank" type="button" class="button" value="銀行件修改">
		</td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="areaB0">
	<tr class=tbYellow0 align=middle>
		<td align=middle>
			<strong>
				<a href="#A_divB0" id="A_divB0">土地訊息</a>
			</strong>
		</td>
	</tr>
	<tr class=tbYellow align=middle>
		<td align=middle>
			<div id="div_B0" style="overflow:auto; display:block;">
				<table id="grid0" class="grid" width="100%"></table>
			</div>
		</td>
	</tr>
</table>
<div style='margin-top: 2px;'></div>
<table id="grid" class="grid" width="100%"></table>
<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="areaB">
	<tr>
		<td class="tbYellow" width="15%">
			受理編號
		</td>
		<td class="tbYellow2" width="25%">
			<span id="OLD_APPLY_ID"></span>
		</td>
		<td class="tbYellow" width="15%">
			受理進度
		</td>
		<td class="tbYellow2" width="45%">
			<span id="APPLY_PROCESS_NM"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			抵押土地座落
		</td>
		<td id="DSZ01000" class="tbYellow2" colspan=3></td>
	</tr>
	<tr>
		<td class="tbYellow">
			地號
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="LAND_NO1" name="LAND_NO1" type="text" class="textBox2" datatype="number" pattern ="###" size="4" maxlength="4" value="">
			-
			<input id="LAND_NO2" name="LAND_NO2" type="text" class="textBox2" datatype="number" pattern ="###" size="4" maxlength="4" value="">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			土地面積
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="LAND_MEASURE" name="LAND_MEASURE" type="text" class="textBox2" datatype="number" intLength="6" decLength="3" pattern ="#,###.###" size="11" maxlength="11" value="">
			平方公尺
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			最新公告年度
		</td>
		<td class="tbYellow2" colspan=3>
			民國<input id="ANNOU_YEAR" name="ANNOU_YEAR" type="text" class="textBox2" datatype="number" pattern ="###" size="3" maxlength="3" value="">
			年，公告現值
			<input id="ANNOU_VALUE" name="ANNOU_VALUE" type="text" class="textBox2" datatype="number" intLength="7" decLength="2" pattern ="#,###.##" size="12" maxlength="12" value="">
			元/平方公尺
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			所有權人
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="NAME" name="NAME" type="text" class="textBox2" size="80" maxlength="100" value="" alt="ch"/><%--[20247023]難字調整 --%>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			所有權人ID
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="ID" name="ID" type="text" class="textBox2" size="15" maxlength="10" value="">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			所有權人生日
		</td>
		<td class="tbYellow2" colspan=3>
			<span id="BIRTHDAY"></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			持分
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="HOLD_BASE" name="HOLD_BASE" type="text" class="textBox2" size="20" datatype="number" intLength="15" pattern ="#,###"  maxlength="19" value="">
			分之
			<input id="HOLD_UP" name="HOLD_UP" type="text" class="textBox2" size="20" datatype="number" intLength="15" pattern ="#,###"  maxlength="19" value="">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			移轉年月
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="TRAN_DATE" name="TRAN_DATE" type="text" class="textBox2" size="5" maxlength="5" value="">
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			前次移轉現值
		</td>
		<td class="tbYellow2" colspan=3>
			<input id="TRAN_VALUE" name="TRAN_VALUE" type="text" class="textBox2" datatype="number" intLength="7" decLength="2" pattern ="#,###.##" size="12" maxlength="12" value="">
			元/平方公尺
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			土地屬性
		</td>
		<%--[20250217]調整土地屬性(使用分區)、土地屬性(使用地類別)下拉選單初始方式--%>		
		<td class="tbYellow2" colspan=3>			
			使用分區： 
			<select id="USE_SECT" name="USE_SECT" class="textBox2" disabled>
				<c:forEach var="entry" items="${USE_SECT_Map}">
	    			<option value="${entry.key}">${entry.value}</option>
    			</c:forEach>
			</select>
			使用地類別：
			<select id="USE_KIND" name="USE_KIND" class="textBox2" disabled>
				<c:forEach var="map" items="${USE_KIND_Map}">
			    	<option value="${map.key}">${map.value}</option>
		    	</c:forEach>
			</select>
			地目：
			<select id="LAND_POS" name="LAND_POS" class="textBox2">
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			輸入人員
		</td>
		<td class="tbYellow2">
			<span id="INPUT_ID" style="display:none"></span>
			<span id="INPUT_NM" style="font-family:'EUDC'"></span><%--[20240723]難字調整 --%>
		</td>
		<td class="tbYellow">
			輸入日期
		</td>
		<td class="tbYellow2">
			<span id="INPUT_DATE"></span>
		</td>
	</tr>
</table>
</form>
</body>
</html>