<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA60600.jsp
功能：覆審土地謄本輸入
作者：徐立錡
完成：2022/08/11
[20241001] 修改件 CHROME瀏覽器難字調整 
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" />
<!--匯入外部Javascript 與 css-->
<title></title>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
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
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/prototype.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<!-- 必要 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/JavaScript" src="${htmlBase}/DS/js/DSZ01000.js"></script>


<script type="text/JavaScript">
Event.observe(window, 'load', new DSA60600().initApp);

function DSA60600(){
	
	var valid;  <%--查詢用--%>
	var valid2; <%--新增用--%>
	var valid3; <%--刪除用--%>
	var valid4; <%--修改用--%>
    var grid;
    var record; <%--後端回傳當下畫面的值--%>
    var rtnMap; <%--後端回傳rtnMap--%>
    var SEQ_NO; <%--刪除用，取得當前的SEQ_NO--%>
    var address3 <%--new出 DSZ01000--%>
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0600/');
	 
	//畫面檢核
	function initValidation(){
		valid = new Validation('form1', { mode :"validate"} );
		valid.define( "required" , { id: "APPLY_ID", errMsg : "受理編號不可為空"} );
		valid.define( "required" , { id: "REV_YM", errMsg : "覆審年月不可為空"} );
		
		valid2 = new Validation('form2', { mode :"validate"} );
		valid2.define( "validate-selection" , { id: "DSZ01000_CITY_NAME", errMsg : "抵押土地座落(市)不可為空"} );
		valid2.define( "validate-selection" , { id: "DSZ01000_TOWN_NAME", errMsg : "抵押土地座落(鄉鎮市區)不可為空"} );
		valid2.define( "validate-selection" , { id: "DSZ01000_OFFICE_NAME", errMsg : "抵押土地座落(段)不可為空"} );
		valid2.define( "validate-selection" , { id: "DSZ01000_LAND_NAME1", errMsg : "抵押土地座落(小段)不可為空"} );
		
		valid2.define( "validate-positive-number" , { id: "LAND_MEASURE", errMsg : "請輸入有效正數"} );
		valid2.define( "validate-digits" , { id: "ANNOU_YEAR", errMsg : "請輸入有效正整數"} );
		valid2.define( "validate-number" ,{ id : "LAND_NO1", errMsg : "請輸入有效數字格式"});
		valid2.define( "validate-number" ,{ id : "LAND_NO2", errMsg : "請輸入有效數字格式"});
		valid2.define( "validate-positive-number" , { id: "ANNOU_VALUE", errMsg : "請輸入有效正數"} );
		valid2.define( "validate-digits" , { id: "HOLD_BASE", errMsg : "請輸入有效正整數"} );
		valid2.define( "validate-digits" , { id: "HOLD_UP", errMsg : "請輸入有效正整數"} );
		valid2.define( "validate-positive-number" , { id: "TRAN_VALUE", errMsg : "請輸入有效正數"} );
		
		valid2.define( "required" , { id: "LAND_NO1", errMsg : "地號(一)不可為空"} );
		valid2.define( "required" , { id: "LAND_NO2", errMsg : "地號(二)不可為空"} );
		valid2.define( "required" , { id: "LAND_MEASURE", errMsg : "土地面積不可為空"} );
		valid2.define( "required" , { id: "ANNOU_YEAR", errMsg : "最新公告年度不可為空"} );
		valid2.define( "required" , { id: "ANNOU_VALUE", errMsg : "公告現值不可為空"} );
		valid2.define( "required" , { id: "NAME", errMsg : "所有權人不可為空"} );
		valid2.define( "required" , { id: "ID", errMsg : "所有權人ID不可為空"} );
		valid2.define( "required" , { id: "HOLD_UP", errMsg : "持分(分子)不可為空"} );
		valid2.define( "required" , { id: "HOLD_BASE", errMsg : "持分(分母)不可為空"} );
		valid2.define( "required" , { id: "TRAN_DATE", errMsg : "移轉年月不可為空"} );
		valid2.define( "required" , { id: "TRAN_VALUE", errMsg : "前次移轉現值不可為空"} );
		valid2.define( "valid_NAME_check" , { id: "NAME"} );
		valid2.define( "valid_HOLD_check" , [{ id: 'HOLD_BASE' }, { id: 'HOLD_UP'}] );
		
		valid3 = new Validation('form1', { mode :"validate"} );
		valid3.define( "valid_APPLY_ID_check" , [{ id: "APPLY_ID" , errMsg : "欲刪除的受理編號與原先查詢的資料不同，無法作業!"}, 
			{ id : 'OLD_APPLY_ID', errMsg : "欲刪除的受理編號與原先查詢的資料不同，無法作業!"}] );
		
		valid4 = new Validation('form1', { mode :"validate"} );
		valid4.define( "valid_APPLY_ID_check" , [{ id: "APPLY_ID" , errMsg : "欲修改的受理編號與原先查詢的資料不同，無法作業!"}, 
			{ id : 'OLD_APPLY_ID', errMsg : "欲修改的受理編號與原先查詢的資料不同，無法作業!"}] );


		
		Validation.addAllThese( [
			[ "valid_NAME_check", '所有權人不可輸入半形字', function(NAME){
				return !validation.hasHalfType(NAME);;
		    }],
			[ "valid_HOLD_check", '分母不可小於分子!', function(HOLD_BASE, HOLD_UP){
				if(HOLD_BASE != '' || HOLD_UP != ''){
					return parseFloat(HOLD_BASE) >= parseFloat(HOLD_UP);
				}
				return true;
		    }],
			[ "valid_APPLY_ID_check", '', 
				function(APPLY_ID, OLD_APPLY_ID){
					var chkId = false;
					if(APPLY_ID == OLD_APPLY_ID){
						chkId = true;
					}
					return chkId;
				} 
			]
		]);
	};
	
	function buttonAuth(){
		var authButtons = {
			B0003:'btn_insert',<%--新增--%>
			B0004:'btn_update',<%--修改--%>
			B0005:'btn_delete',<%--刪除--%>
			B0024:'btn_link1'<%--土地謄本影像--%>
		};
		<dz:grantButtons FUNC_ID="DSA60600" ignored="false"/>
	}
	
	var actions = {
		updateBInfo : function(rtnMap, record){
			
			if(rtnMap){
				$('OLD_APPLY_ID').update(rtnMap.APPLY_ID || '');
				$('APPR_PROCESS_NM').update(rtnMap.APPR_PROCESS_NM || '');
				
				<%-- 抵押土地座落 下拉選項--%>
				address3.setCITY_NAME(rtnMap.CITY);
				
				$('APPR_PROCESS').setValue(rtnMap.APPR_PROCESS || '');
				$('OLD_REV_YM').setValue(rtnMap.REV_YM || '');
				$('LOAN_ID').setValue(rtnMap.LOAN_ID || '');
				$('REFER_ID').setValue(rtnMap.REFER_ID || '');
				$('REV_DEPT_CODE').setValue(rtnMap.REV_DEPT_CODE || '');
				$('REV_KIND').setValue(rtnMap.REV_KIND || '');
				$('REV_TYPE').setValue(rtnMap.REV_TYPE || '');
			}
			
			if(record){
				<%-- 抵押土地座落 下拉選項--%>
				var townName = record.LOCATION1;
				address3.setTOWN_NAME(townName);
				var landName1 = record.LOCATION2;
				address3.setLAND_NAME1(landName1);
				var landName2 = record.LOCATION3;
				address3.setLAND_NAME2(landName2);

				$('LAND_NO1').setValue(record.LAND_NO1 || '');
				$('LAND_NO2').setValue(record.LAND_NO2 || '');
				$('LAND_MEASURE').setValue(record.LAND_MEASURE || '');
				$('ANNOU_YEAR').setValue(record.ANNOU_YEAR || '');
				$('ANNOU_VALUE').setValue(record.ANNOU_VALUE || '');
				$('NAME').setValue(record.NAME || '');
				$('ID').setValue(record.ID || '');
				//$('BIRTHDAY').update(localeDisplay.formatDate(record.BIRTHDAY)|| '');
				$('HOLD_BASE').setValue(record.HOLD_BASE || '');
				$('HOLD_UP').setValue(record.HOLD_UP || '');
				$('TRAN_DATE').setValue(record.TRAN_DATE || ''); 
				$('TRAN_VALUE').setValue(record.TRAN_VALUE || '');
				<%-- 土地屬性 下拉選項--%>
				$('USE_SECT').setValue(record.USE_SECT || '');
				$('USE_KIND').setValue(record.USE_KIND || '');
				$('LAND_POS').setValue(record.LAND_POS || '');
				
				$('INPUT_ID').setValue(record.INPUT_ID || '');
				$('INPUT_NM').update(record.INPUT_NM || '');
				$('INPUT_DATE').update(localeDisplay.formatDate(record.INPUT_DATE)|| '');
			}
		},
		clearData : function(){

   			grid.load([]);

   			$$('#form2 input[type="text"]').each(
   	   			function(text){
   	   				// 執行清除
   					$(text).setValue('');
   	   			}
   	   		);
   			// 因為用 dateymFields='TRAN_DATE' 方法導致無法用setValue清除，所以額外再清除TRAN_DATE
   			$('TRAN_DATE').value='';
   			
   			$$('#form2 input[type="hidden"]').each(
   	   	   		function(text){
   	   	   			// 執行清除
   					$(text).setValue('');
   	   	   		}
   	   	   	);
   			
   			$$('#form2 span').each(
 	   	   		function(text){
 	   	   			// 執行清除
 	   	   			$(text).update('');
 	   	   		}
 	   	   	);
   				
   			$w('USE_SECT USE_KIND LAND_POS').each(
   				function(key){
   					$(key).options[0].selected = true;
   				}
   			);

   			address3.setCITY_NAME("");
		},
		toFixLength : function(event){  <%-- 地號連動(前面補0至固定長度) --%>
			var target = event.type != 'text' ? event.target: event;
			if($(target).getValue().trim() != ''){
				var targetValue = $(target).getValue().trim();
				var maxLength = parseInt($(target).maxLength, 10);
				var defaultValue = '0'.times(maxLength);
				var diffLength = defaultValue.length - targetValue.length;
				if(diffLength != 0){
					$(target).setValue(defaultValue.substring(0, diffLength) + targetValue);
				}
			}
		}
	};
	
	var buttons = {
		<%-- 查詢 --%>
		doQuery : function(){			
			valid.reset();
			valid2.reset();			
			valid3.reset();			
			valid4.reset();			
			if(!valid.validate()){
				return;
			}		

			var reqMap = {
					APPLY_ID  : $F("APPLY_ID") 
					,REV_YM   : $F('REV_YM')
			};
			
			//保留參數管理
			CSRUtil.keepParamsManager.put({'APPLY_ID': $F("APPLY_ID") });
			CSRUtil.keepParamsManager.put({'REV_YM': $F('REV_YM') });
			
			<%-- 發送AJAX --%>
			ajaxRequest.post('query' , { reqMap : Object.toJSON(reqMap)},
				function(resp){
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = rtnMap.rtnList || [];
					grid.load(rtnList || []);
				},function(resp){
					actions.clearData();
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					actions.updateBInfo(rtnMap, null);
				}
			);
	    },
		<%-- 新增 --%>
		doInsert : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();	
			valid4.reset();			
			if(!valid2.validate()){
				return;
			}
			
			// 檢核查詢用和顯示用受理編號是否不同
			if($F("APPLY_ID") != $('OLD_APPLY_ID').innerHTML){
				var msg = '請確認是否將資料新增到此【'+ $F('APPLY_ID') +'】中?';
				if(!confirm(msg)){
					return;
				}
			}
			
			var reqMap = {
					APPLY_ID       : $F("APPLY_ID") 
					,REV_YM        : $F('REV_YM')
					,LAND_NO1      : $F('LAND_NO1')
					,LAND_NO2      : $F('LAND_NO2')
					,ID            : $F('ID')
					,TRAN_DATE     : $F('TRAN_DATE')
					//,BIRTHDAY      : $('BIRTHDAY').innerHTML
					,LOCATION1     : address3.getTOWN_NAME()
					,LOCATION2     : address3.getLAND_NAME1()
					,LOCATION3     : address3.getLAND_NAME2()
					,LAND_MEASURE  : $F('LAND_MEASURE')
					,ANNOU_YEAR    : $F('ANNOU_YEAR')
					,ANNOU_VALUE   : $F('ANNOU_VALUE')
					,NAME          : $F('NAME')
					,HOLD_UP       : $F('HOLD_UP')
					,HOLD_BASE     : $F('HOLD_BASE')
					,TRAN_VALUE    : $F('TRAN_VALUE')
					,USE_SECT      : $F('USE_SECT')
					,USE_KIND      : $F('USE_KIND')
					,LAND_POS      : $F('LAND_POS')
					,APPR_PROCESS  : $F('APPR_PROCESS')
					,LOAN_ID       : $F('LOAN_ID')
					,REFER_ID      : $F('REFER_ID')
					,REV_DEPT_CODE : $F('REV_DEPT_CODE')
					,REV_KIND      : $F('REV_KIND')
					,REV_TYPE      : $F('REV_TYPE')
			};
			<%-- 發送AJAX --%>
			ajaxRequest.post('insert' , { reqMap : Object.toJSON(reqMap)},
				function(resp){		
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = rtnMap.rtnList || [];
					grid.load(rtnList || []);
				}
			);
	    },
	    <%-- 刪除 --%>
		doDelete : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			valid4.reset();			
			if(!valid3.validate()){
				return;
			}
			
			// 顯示確認訊息‘是否確認刪除?’，確認後才繼續執行
			if(!confirm('是否確認刪除?')){
				return;
			}
			
			var reqMap = {
					APPLY_ID       : $('OLD_APPLY_ID').innerHTML 
					,SEQ_NO        : SEQ_NO          // 刪除指定SEQ_NO筆數
					,REV_YM        : $F('OLD_REV_YM')
					,APPR_PROCESS  : $F('APPR_PROCESS')
					,LOAN_ID       : $F('LOAN_ID')
					,REFER_ID      : $F('REFER_ID')
					,REV_DEPT_CODE : $F('REV_DEPT_CODE')
					,REV_KIND      : $F('REV_KIND')
					,REV_TYPE      : $F('REV_TYPE')
			};
			<%-- 發送AJAX --%>
			ajaxRequest.post('delete' , { reqMap : Object.toJSON(reqMap)},
				function(resp){
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = rtnMap.rtnList || [];
					grid.load(rtnList || []);
				}
			);
	    },
	    <%-- 修改 --%>
		doUpdate : function(){
			valid.reset();
			valid2.reset();
			valid3.reset();
			valid4.reset();			
			if(!valid2.validate()||!valid4.validate()){
				return;
			}
			var reqMap = {
					APPLY_ID       : $('OLD_APPLY_ID').innerHTML 
					,SEQ_NO        : SEQ_NO          // 修改指定SEQ_NO筆數
					,REV_YM        : $F('OLD_REV_YM')
					,LAND_NO1      : $F('LAND_NO1')
					,LAND_NO2      : $F('LAND_NO2')
					,ID            : $F('ID')
					,TRAN_DATE     : $F('TRAN_DATE')
					,LOCATION1     : address3.getTOWN_NAME()
					,LOCATION2     : address3.getLAND_NAME1()
					,LOCATION3     : address3.getLAND_NAME2()
					,LAND_MEASURE  : $F('LAND_MEASURE')
					,ANNOU_YEAR    : $F('ANNOU_YEAR')
					,ANNOU_VALUE   : $F('ANNOU_VALUE')
					,NAME          : $F('NAME')
					,HOLD_UP       : $F('HOLD_UP')
					,HOLD_BASE     : $F('HOLD_BASE')
					,TRAN_VALUE    : $F('TRAN_VALUE')
					,USE_SECT      : $F('USE_SECT')
					,USE_KIND      : $F('USE_KIND')
					,LAND_POS      : $F('LAND_POS')
					,APPR_PROCESS  : $F('APPR_PROCESS')
					,LOAN_ID       : $F('LOAN_ID')
					,REFER_ID      : $F('REFER_ID')
					,REV_DEPT_CODE : $F('REV_DEPT_CODE')
					,REV_KIND      : $F('REV_KIND')
					,REV_TYPE      : $F('REV_TYPE')
			};
			<%-- 發送AJAX --%>
			ajaxRequest.post('update' , { reqMap : Object.toJSON(reqMap)},
				function(resp){
					rtnMap = resp.rtnMap ? resp.rtnMap : {};
					var rtnList = rtnMap.rtnList || [];
					grid.load(rtnList || []);
				}
			);
	    },
		<%-- 清除 --%>
	    doClear : function(){
	    	valid.reset();
			valid2.reset();
			valid3.reset();
			valid4.reset();	
			actions.clearData();
   			$$('#form1 input[type="text"]').each(
   				function(text){
   					// 執行清除
   					$(text).setValue('');
   				}
   			);
	    },
	 	<%-- 超連結－土地謄本影像 --%>
		doLink1:function(){
			popupWin.windowOpen('${dispatcher}/DSA0_0200/prompt',{
				'parameters': {'APPLY_ID': $('OLD_APPLY_ID').innerHTML},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		}
    };

	return{
	
		initApp : function(){
			<%-- 初始格式化套件 --%>
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" dateymFields="TRAN_DATE" 
				numberFields="LAND_MEASURE ANNOU_VALUE HOLD_BASE HOLD_UP TRAN_VALUE"/>
			<%-- 建立基本頁面 --%>
			PageUI.createPageWithAllBodySubElement("DSA60600" , "覆審作業" ,"覆審土地謄本輸入");
			<%--[20241001]難字調整--%>
			grid = new TableUI({
				table: $('grid'), pageSize: 1, allSortable: false,
				pageChange:function(pageNO){
					var record_no = pageNO - 1;
					var allRecords = grid.getAllRecords();
					if(record_no < 0 || record_no >= allRecords.length ){ return;}
					
					record = allRecords[record_no];
					SEQ_NO = record.SEQ_NO; // 刪除指定SEQ_NO筆數
					actions.updateBInfo(rtnMap, record);
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:[
					{header:'序號', key:'SEQ_NO'},
					{header:'地號', key:'LAND_NO1',
						render:function(record, value){
							var LAND_NO1 = record.LAND_NO1;
							var LAND_NO2 = record.LAND_NO2;
							return LAND_NO1 + " - " + LAND_NO2;
						}
					},
					{header:'所有權人', key:'NAME', style:"font-family:'EUDC'"},
					{header:'移轉年月', key:'TRAN_DATE',
						render:function(record, value){
							var date = localeDisplay.formatDateym(value);
							if(date && (date.length == 4)){
								return date.substring(0, 2) + '/' + date.substring(2, 4);
							} else {
								return date.substring(0, 3) + '/' + date.substring(3, 5);
							}
						}
					}
				]
			});		
			
			
			
			<%-- include  DSZ01000.jsp 取得物件區塊 --%>
			address3 = new DSZ01000("DSZ01000", "3"); <%-- 傳入參數:作業編號FUNC_ID = FUNC_ID 作業種類INPUT_TYPE = '3' --%>
			
			// 抵押土地座落的縣市別不可變動，所以disable
			var selectObj = address3.getAllSelectObject();
			selectObj.CITY_NAME.disable();
			
			<%-- 按鈕事件監聽 --%>
			$('btn_query').observe('click', buttons.doQuery);   <%--查詢--%>
			$('btn_insert').observe('click', buttons.doInsert); <%--新增--%>
			$('btn_delete').observe('click', buttons.doDelete); <%--刪除--%>
			$('btn_update').observe('click', buttons.doUpdate); <%--修改--%>
			$('btn_clear').observe('click', buttons.doClear);   <%--清除--%>
			$('btn_link1').observe('click', buttons.doLink1);   <%--土地謄本影像--%>
			$w('LAND_NO1 LAND_NO2').each(function(eleId){
				$(eleId).observe("blur", actions.toFixLength);
			});
 			buttonAuth();
			initValidation();
			
			if ('${APPLY_ID}' != "") {//接值
				$('APPLY_ID').value = '${APPLY_ID}';
				$('REV_YM').value = '${REV_YM}';
			} else { 
				//保留參數管理
				$('APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
				$('REV_YM').value = CSRUtil.keepParamsManager.get('REV_YM');
			}			
			if($('APPLY_ID').value){
				buttons.doQuery();
			}
			
			<%-- 顯示訊息 --%>
			displayMessage();
		}	
		
	};
	
}
</script>
</head>
<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
<table  id="form1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">
			受理編號
		</td>
		<td class="tbYellow2" width="15%">
			<input id="APPLY_ID" name="APPLY_ID" type="text" class="textBox2" size="15" maxlength="11">
		</td>
		<td class="tbYellow" width="10%">
			覆審年月<font color="red">※例：11010</font>
		</td>
		<td class="tbYellow2" width="15%">
			<input id="REV_YM" name="REV_YM" type="text" class="textBox2" size="7" maxlength="5">
		</td>
		<td class="tbYellow2" align="left" width="50%">
			<button type="button" class="button" id="btn_query">查詢</button>
			<button type="button" class="button" id="btn_link1">土地謄本影像</button>
		</td>
	</tr>
	<tr>
		<td align="center" colspan="5">
			<button type="button" class="button" id="btn_insert">新增</button>
			<button type="button" class="button" id="btn_delete">刪除</button>
			<button type="button" class="button" id="btn_update">修改</button>
			<button type="button" class="button" id="btn_clear">清除</button>
		</td>
	</tr>
</table>
<table id="grid" class="grid" width="100%"></table>
<table id="form2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
	<tr>
		<td class="tbYellow" width="15%">
			受理編號
		</td>
		<td class="tbYellow2" width="25%">
			<span id="OLD_APPLY_ID"></span>
		</td>
		<td class="tbYellow" width="15%">
			覆審鑑價進度
		</td>
		<td class="tbYellow2" width="45%">
			<span id="APPR_PROCESS_NM"></span>
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
			<%--[20241001]難字調整--%>
			<input id="NAME" name="NAME" type="text" class="textBox2" size="80" maxlength="100" value="" alt="ch">
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
	<!-- <tr>
		<td class="tbYellow">
			所有權人生日
		</td>
		<td class="tbYellow2" colspan=3>
			<span id="BIRTHDAY"></span>
		</td>
	</tr> -->
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
		<td class="tbYellow2" colspan=3>
			使用分區：
			<select class="textBox2" id="USE_SECT" name="USE_SECT" title="使用分區" ><%-- 使用分區 --%>
				<c:forEach var="map" items="${USE_SECT_LIST}">
					<option value="${map.CODE}">${map.CODE_NM}</option>
				</c:forEach>
			</select>
			使用地類別：
			<select class="textBox2" id="USE_KIND" name="USE_KIND" title="使用地類別" ><%-- 使用地類別 --%>
				<c:forEach var="map" items="${USE_KIND_LIST}">
					<option value="${map.CODE}">${map.CODE_NM}</option>
				</c:forEach>
			</select>
			地目：
			<select class="textBox2" id="LAND_POS" name="LAND_POS" title="地目" ><%-- 地目 --%>
				<c:forEach var="map" items="${LAND_POS_LIST}">
					<option value="${map.CODE}">${map.CODE_NM}</option>
				</c:forEach>
			</select>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">
			輸入人員
		</td>
		<td class="tbYellow2">
			<input id="INPUT_ID" name="INPUT_ID" type="hidden" >
			<%--[20241001]難字調整--%>
			<span id="INPUT_NM" style="font-family:'EUDC'"></span>
		</td>
		<td class="tbYellow">
			輸入日期
		</td>
		<td class="tbYellow2">
			<span id="INPUT_DATE"></span>
			<input id="APPR_PROCESS" name="APPR_PROCESS" type="hidden" >
			<input id="OLD_REV_YM" name="OLD_REV_YM" type="hidden" >
			<input id="LOAN_ID" name="LOAN_ID" type="hidden" >
			<input id="REFER_ID" name="REFER_ID" type="hidden" >
			<input id="REV_DEPT_CODE" name="REV_DEPT_CODE" type="hidden" >
			<input id="REV_KIND" name="REV_KIND" type="hidden" >
			<input id="REV_TYPE" name="REV_TYPE" type="hidden" >
		</td>
	</tr>
</table>
</body>
</html>