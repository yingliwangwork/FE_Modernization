<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!--
程式：DSA60700.jsp
作者：郭曉慧
功能：覆審建物謄本輸入
完成：20220809
[20241001] 修改件 CHROME瀏覽器難字調整 
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<title></title>
<link href="${cssBase}/cm.css" rel="stylesheet" type="text/css" />
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
<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script> <%-- JS基礎底層必備用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script> <%-- CSR相關處理用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script> <%-- 標準外框表格 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script> <%-- 表格用 --%>
<script type="text/javascript" src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script><%-- 檢核用 --%>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script><%-- 日曆用 --%>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js"></script>

<script type='text/javascript'>

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', new DSA60700().initApp);

function DSA60700(){
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA6_0700/');
	var A290Map = {};
	var gridB, gridD, gridE;
	var valid;

	var buttons = {
		doQuery: function(){
			if(!actions.resetValid($(this))){
				return;
			}
			//保留參數管理
			CSRUtil.keepParamsManager.put({'APPLY_ID': $F('Q_APPLY_ID') });
			CSRUtil.keepParamsManager.put({'REV_YM': $('Q_REV_YM').value });
			
			A290Map = {};
			ajaxRequest.post('query', {'reqMap': Object.toJSON(actions.getQueryParam())}, 
				function(resp){
					actions.setData(resp.rtnMap);
				},
				function(resp){
					actions.setData(resp.rtnMap);
				}
			); 
		},
		doInsert: function(){ 
			if(!actions.commonValid($(this))){
				return;
			}
			var reqMap = actions.getBlockCData();
			if($F('Q_APPLY_ID') != $('APPLY_ID').innerHTML){
				var msg = '請確認是否將資料新增到此【'+ $F('Q_APPLY_ID') +'】中?';
				if(!confirm(msg)) {
					return ;
				}else{
					reqMap.APPLY_ID = $F('Q_APPLY_ID');
				}
			}
			var A294List = actions.getGridDData();
			var A295List = actions.getGridEData();
			ajaxRequest.post('insert', {'reqMap': Object.toJSON(reqMap)
				, 'A294List': Object.toJSON(A294List), 'A295List': Object.toJSON(A295List)}, 
				function(resp){
					actions.setData(resp.rtnMap);
				}
			);
		},
		doDelete: function(){  <%-- 刪除 --%>
			if($F('Q_APPLY_ID') != $('APPLY_ID').innerHTML){
				alert('欲刪除的受理編號與原先查詢的資料不同，無法作業!');
				return;
			}
			<%-- [20220816]補檢核 --%>
			if(gridB.getCheckedRecords() == 0){
				alert('請先選擇一筆資料');
				return;
			}
			if(!confirm('是否確認刪除?')){
				return;
			}
			ajaxRequest.post('delete', {'reqMap': Object.toJSON(actions.getDeleteParam())}, 
				function(resp){
					actions.setData(resp.rtnMap);
				}
			); 
		},	
		doModify: function(){  <%-- 修改 --%>
			if($F('Q_APPLY_ID') != $('APPLY_ID').innerHTML){
				alert('欲修改的受理編號與原先查詢的資料不同，無法作業!')
				return;
			}	
			if(!actions.commonValid($(this))){
				return;
			}
			if(!$F('OCCUR_DATE') && !confirm('請確認建物原因發生日期是否正確?')){
				return false;
			}
			if(!confirm("請再次檢視門牌地址與建物謄本資料是否相符?")) {
				return false;
			}
			var reqMap = actions.getBlockCData();
			var selectData = gridB.getCheckedRecords()[0];
			reqMap.OLD_BUILD_NO1 = selectData.BUILD_NO1;
			reqMap.OLD_BUILD_NO2 = selectData.BUILD_NO2;
			var A294List = actions.getGridDData();
			var A295List = actions.getGridEData();
			ajaxRequest.post('modify', {'reqMap': Object.toJSON(reqMap)
				, 'A294List': Object.toJSON(A294List), 'A295List': Object.toJSON(A295List)}, 
				function(resp){
					actions.setData(resp.rtnMap);
				}
			); 
		},
		doClear: function(){  <%-- 清除 --%>
			valid.reset();
			actions.setData();
			$('Q_APPLY_ID').setValue('');
			<%-- [20220816]bug fix:覆審年月沒清掉 --%>
			$('Q_REV_YM').value = '';
		},
		doOpenDSA00200: function(){ <%-- 建物謄本影像--%>
			popupWin.windowOpen('${dispatcher}/DSA0_0200/prompt', {
				'parameters': {'APPLY_ID': $F('Q_APPLY_ID')},
				'fullScreen': false,
				'attributes': {'resizable': 'yes'}
			});
		},
		doAddGridD: function(){ <%-- 新增建物樓層資料 --%>
			if(Object.keys(A290Map).length == 0){
				alert('請先查詢再行操作');
				return;
			}
			gridD.addRecords({});
		},
		doRemoveGridD: function(){ <%-- 移除建物樓層資料 --%>
			var selected = gridD.getCheckedRecord();
			if(selected.length == 0){
				alert('請選取一筆資料');
				return;
			}
			gridD.deleteRecords(selected);
			actions.calTotalBUILD_MEASURE();
		},
		doAddGridE: function(){ <%-- 新增建物所有權人 --%>
			if(Object.keys(A290Map).length == 0){
				alert('請先查詢再行操作');
				return;
			}
			gridE.addRecords({});
		},
		doRemoveGridE: function(){ <%-- 移除建物所有權人 --%>
			var selected = gridE.getCheckedRecord();
			if(selected.length == 0){
				alert('請選取一筆資料');
				return;
			}
			gridE.deleteRecords(selected);
		}
	};
	
	var actions = {
		queryDetail: function(selectedMap){ <%-- 查詢明細 --%>
			if(!selectedMap){
				actions.setDetail();
				return;
			}
			ajaxRequest.post('queryDetail', {'rtnA293Map': Object.toJSON(selectedMap)}, 
				function(resp){
					actions.setDetail(resp.rtnMap, selectedMap);
				}
			); 
		},
		chgQ_APPLY_ID: function(){   <%-- 受理編號連動 --%> 
			$(this).setValue($F(this).toUpperCase());
		},
		toFixLength: function(event){  <%-- 建號連動(前面補0至固定長度) --%>
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
		},
		chgUSE_STATUS: function(){ <%-- 使用情形號連動 --%>
			if(!['1', '4'].include($F(this))){
				['RENTAL', 'DEPOSIT', 'START_DATE', 'END_DATE'].each(function(id){
					$(id).setValue(id.endsWith('_DATE') ? '': '0');
					$(id).disable();
				});
			}else{
				['RENTAL', 'DEPOSIT', 'START_DATE', 'END_DATE'].each(function(id){
					if(!id.endsWith('_DATE')){
						$(id).setValue('');
					}
					$(id).enable();
				});
			}
		},
		chgCELL_NO: function(){ <%-- 建物樓層資料-層次下拉選單連動 --%>
			$(this).up('td').select('input', 'span').each(function(ele){
				ele.hide();
				if(ele.type){
					ele.setValue('');
				}
			});
			<%--
				此處的value值是下拉實際的值，而不是最後資料庫中CELL_NO所歸納完的值
				1  ==> 層次
				V  ==> 其他
				非以上 ==> 非層次非其他
			--%>
			if($F(this) == '1'){
				$(this).up('td').select('input[name=ITEM]', 'span').each(function(ele){
					ele.show();
				});
			}else if($F(this) == 'V'){
				$(this).up('td').select('input').each(function(ele){
					ele.show();
				});
			}else{
				$(this).up('td').select('input[name!=ITEM]').each(function(ele){
					ele.show();
				});
			}
		},
		calBUILD_AGE: function(){ <%-- 計算屋齡 --%>
			if($F('FINISH_DATE') == '' || !isDate($F('FINISH_DATE'))){
				$('BUILD_AGE').innerHTML = '';
				return;
			}
			var reqMap = {
				APPLY_ID: $('APPLY_ID').innerHTML,
				FINISH_DATE: $F('FINISH_DATE')
			};
			ajaxRequest.post('calBUILD_AGE', {'reqMap': Object.toJSON(reqMap)}, 
				function(resp){
					$('BUILD_AGE').innerHTML = resp.BUILD_AGE;
				}
			); 
		},
		calTotalBUILD_MEASURE: function(){ <%-- 計算總面積 --%>
			ajaxRequest.post('calTotalBUILD_MEASURE', {'dataList': Object.toJSON(gridD.getAllRecords())}, 
				function(resp){
					$('BUILD_MEASURE').innerHTML = resp.BUILD_MEASURE;
				}
			); 
		},
		getSplitValue: function(value, splitSymbol){ <%-- 取得過濾掉splitSymbol的值 --%>
			var newValue = "";
			if(value){
				value = value + "";
				var values = value.split(splitSymbol);
				var length = values.length;

				for(var i = 0; i < length; i++){
					newValue = newValue + values[i];
				}
			}
			return newValue;
		},
		getQueryParam: function(){ <%-- 取查詢參數 --%>
			return {
				APPLY_ID: $F('Q_APPLY_ID'),
				REV_YM: $('Q_REV_YM').value
			};
		},
		getDeleteParam: function(){ <%-- 取刪除參數 --%>
			var reqMap = Object.clone(A290Map);
			reqMap.BUILD_NO1 = $F('BUILD_NO1');
			reqMap.BUILD_NO2 = $F('BUILD_NO2');
			return reqMap;
		},
		getBlockCData: function(){ <%-- 取C1/C2/C3資料 --%>
			var reqMap = Object.clone(A290Map);
			$('blockC1').select('input[type!=radio]', 'select').each(function(ele){
				reqMap[ele.id] = ele.getValue();
			});
			reqMap['MAIN_BUILD'] = $('blockC1').select('input[type=radio]:checked')[0].value;
			//reqMap['BUILD_MEASURE'] = $('BUILD_MEASURE').innerHTML;
			reqMap['BUILD_MEASURE'] = actions.getSplitValue($('BUILD_MEASURE').innerHTML, ","); //總面積 
			$('blockC2').select('input', 'span').each(function(ele){
				if(ele.type){
					reqMap[ele.id] = ele.getValue();
				}else{
					reqMap[ele.id] = ele.innerHTML;
				}
			});
			$('blockC3').select('input', 'select').each(function(ele){
				reqMap[ele.id] = ele.getValue();
			});
			Object.keys(reqMap).each(function(key){
				if(key.endsWith('_DATE') && (!reqMap[key] || reqMap[key] == '')){
					delete reqMap[key];
				}
			});
			return reqMap;
		},
		getGridDData: function(){ <%-- 取建物樓層資料 --%>
			var A294List = gridD.getAllRecords();
			A294List.each(function(data){
				data.APPLY_ID = $F('Q_APPLY_ID');
				data.REV_YM = $('Q_REV_YM').value;
				data.BUILD_NO1 = $F('BUILD_NO1');
				data.BUILD_NO2 = $F('BUILD_NO2');
			});
			return A294List;
		},
		getGridEData: function(){ <%-- 取建物所有權人 --%>
			var A295List = gridE.getAllRecords();
			A295List.each(function(data){
				data.APPLY_ID = $F('Q_APPLY_ID');
				data.REV_YM = $('Q_REV_YM').value;
				data.BUILD_NO1 = $F('BUILD_NO1');
				data.BUILD_NO2 = $F('BUILD_NO2');
			});
			return A295List;
		},
		saveToTableUI: function(){ <%-- 建物樓層資料-輸入框資料回填TableUI --%>
			var dataMap = gridD.getDataObj($(this));
			if($(this).name == 'CELL_NO'){
				if($F(this) == '1'){
					<%--當下拉值為1時，CELL_NO的值應填'A'--%>
					dataMap.CELL_NO = 'A';
				}else if($F(this) == 'V'){
					<%--當下拉值為V時，CELL_NO的值應填'M'--%>
					dataMap.CELL_NO = 'M';
				}else{
					<%--當下拉值為其他時，CELL_NO的值應填'H'--%>
					//dataMap.CELL_NO = $F(this);
					dataMap.CELL_NO = 'H';
					dataMap.ITEM = $F(this);
				}
				return;
			}else if(['AUX_NO1', 'AUX_NO2'].include($(this).name)){
				$(this).setValue(actions.toFixLength($(this)));
			}
			dataMap[$(this).name] = $F(this);
			if(['HOLD_BASE', 'HOLD_UP'].include($(this).name)){
				actions.calTotalBUILD_MEASURE()
			}		
		},
		setData: function(rtnMap){ <%-- 查詢結果回填 --%>
			rtnMap = !rtnMap ? {} : rtnMap;
			actions.resetA290Map(rtnMap);
			var rtnList = rtnMap.rtnList || [];
			gridB.load(rtnList || [], null, null, ['Y']);
			actions.setDetail(rtnMap, rtnList.length == 0 ? {} : rtnList[0]);
		},
		setDetail: function(rtnMap, rtnA293Map){  <%-- 回填明細資料 --%>
			$('blockC1').select('span').each(function(ele){
				if(rtnA293Map){
					ele.innerHTML = A290Map[ele.id] || '';
				}else{
					ele.innerHTML = '';
				}
			});
			var detailMap = rtnA293Map || {};
			$('blockC1').select('input[type!=radio]', 'select').each(function(ele){
				ele.setValue(detailMap[ele.id] || '');
			});
			var BUILD_MEASURE = detailMap['BUILD_MEASURE'] == undefined ? '' : detailMap['BUILD_MEASURE'];
			$('BUILD_MEASURE').innerHTML = localeDisplay.formatNumber(BUILD_MEASURE);
			$('blockC1').select('input[type=radio]').each(function(ele){
				if(ele.value == detailMap.MAIN_BUILD){
					ele.checked = true;
				}else{
					ele.checked = false;
				}
			});
			$('blockC2').select('input', 'span').each(function(ele){
				if(ele.type){
					ele.setValue(detailMap[ele.id] || '');
				}else{
					ele.innerHTML = detailMap[ele.id] || '';
				}
			});
			$('blockC3').select('input', 'select').each(function(ele){
				ele.setValue(detailMap[ele.id] == undefined ? '' : detailMap[ele.id]);
			});
			$('INPUT_NM').innerHTML = detailMap['INPUT_NM'] || '';
			$('INPUT_DATE').innerHTML = '';
			if(detailMap['INPUT_DATE']){
				$('INPUT_DATE').innerHTML = localeDisplay.formatDate(detailMap['INPUT_DATE']);
			}
			$('USE_STATUS').simulate('change');
			rtnMap = !rtnMap ? {} : rtnMap;
			gridD.load(rtnMap.A294List || []);
			gridE.load(rtnMap.A295List || []);
		},
		resetA290Map: function(rtnMap){ <%-- 保留此次查詢A290資料 --%>
			A290Map = {};
			if(!rtnMap || Object.keys(rtnMap).length == 0){
				return;
			}
			var keys = ['APPLY_ID','APPR_PROCESS_NM','GAGE_ADDR','APPR_PROCESS','REV_YM','LOAN_ID'
				,'REFER_ID','REV_DEPT_CODE','REV_KIND','REV_TYPE'];
			keys.each(function(key){
				A290Map[key] = rtnMap[key];
			});
		},
		getCheckGridDKey: function(dataMap){ <%-- 取該筆建物樓層資料需檢核的欄位 --%>
			var keyNameMap = {
				'CELL_NO': '細項序號',
				'ITEM': '項目/層次/其他說明',
				'AUX_NO1': '附屬建號1',
				'AUX_NO2': '附屬建號2',
				'MEASURE': '面積(平方公尺)',
				'HOLD_BASE': '持份(分母)',
				'HOLD_UP': '持份(分子)'
			};
			if(dataMap['CELL_NO'] == 'A'){
				delete keyNameMap['AUX_NO1'];
				delete keyNameMap['AUX_NO2'];
			}else if(dataMap['CELL_NO'] != 'M'){
				delete keyNameMap['ITEM'];
			}
			return keyNameMap;
		},
		checkGridD: function(dataMap){  <%-- 檢核該筆建物樓層資料 --%>
			var checkKeyNameMap = actions.getCheckGridDKey(dataMap);
			var msg = [];
			var errorFieldName = [];
			Object.keys(checkKeyNameMap).each(function(key){
				if(dataMap[key] == ''){
					errorFieldName.push(checkKeyNameMap[key]);
				}
			});
			if(errorFieldName.length > 0){
				msg.push(errorFieldName.join('、') + '[不可空白]');
			}
			errorFieldName = [];
			['MEASURE', 'HOLD_BASE', 'HOLD_UP'].each(function(key){
				if(!actions.checkPositiveNumberNonZero(dataMap[key])){
					errorFieldName.push(checkKeyNameMap[key]);
				}
			});
			if(errorFieldName.length > 0){
				msg.push(errorFieldName.join('、') + '[需為大於零有效正數]');
			}
			if(!actions.checkHold(dataMap['HOLD_BASE'], dataMap['HOLD_UP'])){
				msg.push(checkKeyNameMap['HOLD_BASE'] + '[分母不可小於分子]');
			}
			if(dataMap['CELL_NO'] == 'A' && dataMap['ITEM'] != ''){
				if(!/^[Bb0-9]+$/.test(dataMap['ITEM'])){
					msg.push(checkKeyNameMap['ITEM'] + '[層數資料有誤(請輸入1234567890bB)]');
				}else if(dataMap['ITEM'] == '0'){
					msg.push(checkKeyNameMap['ITEM'] + '[層數資料不得輸入0]');
				}
			}
			return msg.join('，');
		},
		checkGridE: function(dataMap){  <%-- 檢核該筆建物所有權人 --%>
			var keyNameMap = {
				'NAME': '所有權人',
				'ID': '所有權人ID'
			};
			var msg = [];
			var errorFieldName = [];
			Object.keys(keyNameMap).each(function(key){
				if(dataMap[key] == ''){
					errorFieldName.push(keyNameMap[key]);
				}
			});
			if(errorFieldName.length > 0){
				msg.push(errorFieldName.join('、') + '[不可空白]');
			}
			errorFieldName = [];
			if(dataMap['NAME'] != '' && validation.hasHalfType(dataMap['NAME'])){
				errorFieldName.push(keyNameMap['NAME'] + '[不可輸入半型文字]' );
			}
			if(dataMap['ID'] != '' && !(validation.checkUniSN(dataMap['ID']) ||　validation.checkROCID(dataMap['ID']))){
				errorFieldName.push(keyNameMap['ID'] + '[需為有效統一編號格式或身份證字號格式]' );
			}
			if(errorFieldName.length > 0){
				msg.push(errorFieldName.join('，'));
			}
			return msg.join('，');
		},
		genCheckGridMsg: function(dataList){  <%-- 組建物樓層資料/ 建物所有權人檢核訊息--%>
			var msg = [];
			dataList.each(function(dataMap, index){
				if(dataMap.check_Msg != ''){
					var rowPosition = actions.getRecordPosition(index+1);
					msg.push(rowPosition + '：'+dataMap.check_Msg);
				}
			});
			return msg.join('\n');
		},
		checkHold: function(HOLD_BASE, HOLD_UP){ <%-- 建物樓層資料-檢核持份--%>
			if(HOLD_BASE != '' || HOLD_UP != ''){
				var isOk_HOLD_BASE = actions.checkPositiveNumberNonZero(HOLD_BASE);
				var isOk_HOLD_UP = actions.checkPositiveNumberNonZero(HOLD_UP);
				if(isOk_HOLD_BASE && isOk_HOLD_UP){
					return parseFloat(HOLD_BASE) >= parseFloat(HOLD_UP);
				}
			}
			return true;
		},
		checkPositiveNumberNonZero: function(value){ <%-- 建物樓層資料-面積(平方公尺)/持份檢核--%>
			if(value == ''){
				return true;
			}
			return value != '0' && (!isNaN(value) && /^(\d)?\d*(\.\d*)?$/.test(value));
		},
		getRecordPosition: function(seqNo){ <%-- 取建物樓層資料-面積(平方公尺)/持份檢核失敗的資料位置--%>
			var seqNoByPage = seqNo % 10;
			if(seqNoByPage == 0){
				seqNoByPage = 3;
			}
			return '第' + Math.ceil(seqNo / 10) + '頁/第' +seqNoByPage+ '筆';
		},
		commonValid: function(target){ <%-- 新增/修改共用檢核--%>
			var msg = [];
			if(gridD.getAllRecords().length == 0){
				msg.push('建物樓層資料必須至少有一筆資料');
			}
			if(gridE.getAllRecords().length == 0){
				msg.push('建物所有權人資料必須至少有一筆資料');
			}
			if(msg.length > 0){
				alert(msg.join('\n'));
				return;
			}
			if(!actions.resetValid(target)){
				return;
			}
			if(gridD.validTable() != 0){
				msg.push('建物樓層資料\n'+actions.genCheckGridMsg(gridD.getAllRecords()));
			}
			if(gridE.validTable() != 0){
				msg.push('建物所有權人\n'+actions.genCheckGridMsg(gridE.getAllRecords()));
			}
			if(msg.length > 0){
				alert(msg.join('\n'));
				return;
			}
			if(['1', '4'].include($F('USE_STATUS'))) {
				if(!confirm('擔保品出租,請確認月租金押金,租期是否正確?')) {
					return;
				}
			}
			return true;
		},
		resetValid: function(target){ <%--檢核 --%>
			valid.clear();
			valid.reset();
			if('btn_query' == target.id){
				valid.define("required", {id: 'Q_APPLY_ID'});
				valid.define("required", {id: 'Q_REV_YM'});
			}else if(['btn_insert', 'btn_modify'].include(target.id)){
				valid.define("required", {id: 'Q_APPLY_ID'});
				$('blockC1').select('input[type!=radio]', 'select').each(function(ele){
					if(ele.type == 'text'){
						valid.define("required", {id: ele.id});
					}else{
						valid.define("validate-selection", {id: ele.id});
					}
				});
				valid.define("hasFullType", {id: 'ADDR_NO'});
				valid.define("validate-digits", {id: 'FLOOR'});
				valid.define("required", {id: 'FINISH_DATE'});
				if(['1', '4'].include($F('USE_STATUS'))){
					$w('RENTAL DEPOSIT').each(function(eleId){
						valid.define("required", {id: eleId});
						valid.define("validate-digits", {id: eleId});
					});
					valid.define('validate-Date-Interval', [{id: 'START_DATE', ignore: true}, {id: 'END_DATE', errMsg: '租期迄日必須大於租期起日'}]);
				}
				$w('FINISH_DATE OCCUR_DATE START_DATE END_DATE').each(function(eleId){
					valid.define("validate-ROCDate", {id: eleId});
				});
			}
			return valid.validate();
		},
		initValidation: function(){
			valid = new Validation('form1', {focusOnError:true, immediate:false , mode: 'validator'});
		},
		initTableUI: function(){ <%--初始tableUI --%>
			<%--[20241001]難字調整--%>
			gridB = new TableUI ( {
				table: $("gridB"), pageSize: 3 ,allSortable: true, overDiv: true, split: ['BUILD_MEASURE'],
				autoCheckBox:{ type:'radio', text: '選取', attrs: {rowSpan: 2}, valueKey: 'isSelected', 
					action: function(elem, status, data){
						actions.queryDetail(!status ? null : data[0]);	
					}		
				},
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:[
					{header: '建號(主建物建號)', key: "BUILD_NO1", 
						render: function(record, value, sn){
							if(value){
								return value + '-' + record.BUILD_NO2;
							}
						}
					},
					{header: '房屋門牌號碼', key: "ADDR_NO", style:"font-family:'EUDC'", attrs:{ colSpan: 5 }},
					{header: '主要建材', key: "MATERIAL_NM"},
					{header: '主要用途', key: "MAIN_USE_NM"},
					{header: '總層數', key: "FLOOR"},
					{header: '總面積', key: "BUILD_MEASURE"},
					{header: '建築完成日', key: "FINISH_DATE", sortRule: 'date'},
					{header: '屋齡', key: "BUILD_AGE"},
					{header: '原因發生日期', key: "OCCUR_DATE", sortRule: 'date'},
					{header: '使用情形', key: "USE_STATUS_NM"},
					{header: '建築型態', key: "BUILD_TYPE_NM"},
					{header: '月租金', key: "RENTAL", sortRule: 'number'},
					{header: '押金', key: "DEPOSIT", sortRule: 'number'},
					{header: '租期', key: "START_DATE", 
						render: function(record, value, sn){
							if(value){
								return value + '~' + record.END_DATE;
							}
						}
					}
				]
			});	
			var ITEM_LIST = <c:out value="${ITEM_LIST}" default="{}" escapeXml="false" />;
			gridD = new TableUI ( {
				table: $("gridD"), pageSize: 10 ,allSortable: true, overDiv: true
					, title: '建物樓層資料', 
				autoCheckBox:{ type:'radio', text: '選取'}, 
				validateRecord: function(rec, sn){ 
					var check_Msg = actions.checkGridD(rec);
					rec.check_Msg = check_Msg;
					return check_Msg == '';
				},
				column:[
					{header: '項目/層次/建號', key: "ITEM", 
						render: function(record, value, sn){
							var cellNo_select = new Element('select', {name: 'CELL_NO', id: 'CELL_NO'+sn, className: 'textBox2'});
							cellNo_select.add(new Option('請選擇', ''));
							cellNo_select.add(new Option('層次', '1'));
							Object.keys(ITEM_LIST).forEach(function (key) {
								cellNo_select.add(new Option(ITEM_LIST[key], key))
							});
							cellNo_select.add(new Option('其他', 'V'));
							cellNo_select.observe("change", actions.chgCELL_NO);
							var item_input = new Element('input', {type:'text', name: 'ITEM', id: 'ITEM'+sn
								, style: 'margin-left: 5px;', className: 'textBox2', size: 10});
							var span = new Element('span').update('層');
							var auxNo1_input = new Element('input', {type:'text', name: 'AUX_NO1', id: 'AUX_NO1'+sn
								, style: 'margin-left: 5px;', className: 'textBox2', maxLength: 5, size: 8});
							var auxNo2_input = new Element('input', {type:'text', name: 'AUX_NO2', id: 'AUX_NO2'+sn
								, style: 'margin-left: 5px;', className: 'textBox2', maxLength: 3, size: 6});
							var div = new Element('div');
							div.insert(cellNo_select).insert(item_input).insert(span).insert(auxNo1_input).insert(auxNo2_input);
							item_input.hide();
							span.hide();
							auxNo1_input.hide();
							auxNo2_input.hide();
							<%--
								這邊是最終CELL_NO值，依條件決定下拉值
								if 		ITEM_LIST 選擇“層次” then 值 = ‘A’		下拉實值 ==> 1
								elseif 	ITEM_LIST 選擇“其他” then 值 = ‘M’		下拉實值 ==> V
								else值 = ‘H’	下拉實值 ==> !(1,V) 存於ITEM欄位上
								end if 
							--%>
							var CELL_NO_VALUE = record.CELL_NO;
							if (CELL_NO_VALUE == "A" || CELL_NO_VALUE == "B" || CELL_NO_VALUE == "C" || CELL_NO_VALUE == "D" || CELL_NO_VALUE == "E" || CELL_NO_VALUE == "F" || CELL_NO_VALUE == "G") {
								<%--
									value == 1 層次
									下拉及ITEM
								--%>
								cellNo_select.setValue('1');
								item_input.show();
								span.show();
								item_input.setValue(record.ITEM);
							}else if(CELL_NO_VALUE == "M" || CELL_NO_VALUE == "N" || CELL_NO_VALUE == "O") {
								<%--
									value == V其他
								--%>
								cellNo_select.setValue('V');
								[item_input, auxNo1_input, auxNo2_input].each(function(ele){
									ele.show();
									ele.setValue(record[ele.name]);
								});
							} else {
								<%--
									value == H非 層次非其他
									此時 ITEM是用來存下拉的值，ITEM不顯層
								--%>
								cellNo_select.setValue(record.ITEM);
								item_input.setValue(CELL_NO_VALUE);
								[auxNo1_input, auxNo2_input].each(function(ele){
									ele.show();
									ele.setValue(record[ele.name]);
								});
							}
							[cellNo_select, item_input, auxNo1_input, auxNo2_input].each(function(ele){
								ele.observe("blur", actions.saveToTableUI);
							});
							return div;
						}
					},
					{header: '面積(平方公尺)', key: "MEASURE", input: {type: 'number', name: 'MEASURE',
                            action: function(node , dataObj, textDiv, orgData){
                            	actions.calTotalBUILD_MEASURE();
                            }
                       }
					},
					{header: '持份', key: "HOLD_BASE",
						render: function(record, value, sn){
							var holdBase_input = new Element('input', {type:'text', name: 'HOLD_BASE', id: 'HOLD_BASE'+sn
								, style: 'margin-left: 5px;', className: 'textBox2', datatype: 'number', pattern: "##,###"});
							var holdUp_input = new Element('input', {type:'text', name: 'HOLD_UP', id: 'HOLD_UP'+sn
								, style: 'margin-left: 5px;', className: 'textBox2', datatype: 'number', pattern: "##,###"});
							var div = new Element('div');
							div.insert(holdBase_input).insert("分之").insert(holdUp_input);
							holdBase_input.setValue(record.HOLD_BASE);
							holdUp_input.setValue(record.HOLD_UP);
							[holdBase_input, holdUp_input].each(function(ele){
								ele.observe("blur", actions.saveToTableUI);
							});
							return div;
						}
					}
				]
			});
			gridE = new TableUI ( {
				table: $("gridE"), pageSize: 10 ,allSortable: true, overDiv: true
					, title: '建物所有權人',
				autoCheckBox:{type: "radio", text: '選取'},
				validateRecord: function(rec, sn){ 
					var check_Msg = actions.checkGridE(rec);
					rec.check_Msg = check_Msg;
					return check_Msg == '';
				},
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:[
					{header: '所有權人', key: "NAME",
					 render: function(rec,val,sn){
						var input = new Element('input', {
							'type': 'text',
							'name': 'NAME',
							'alt': 'ch'
						}).setValue(val);
						
						input.observe('blur', function(event){
							rec['NAME'] = this.value;
						});
						return input;
					 }
					},
					{header: '所有權人ID', key: "ID", input: {type: 'text', name: 'ID'}}
					//{header: '所有權人生日', key: "BIRTHDAY", sortRule: 'date'}
				]
			});
		},
		buttonAuth: function(){
			var authButtons = {
					B0003: "btn_insert", 
					B0004: "btn_modify",  
					B0005: "btn_delete",
					B0033: "btn_openDSA00200",
				};	
			<dz:grantButtons FUNC_ID="DSA60700" ignored="false"/>			
		}
	};

	return {
		initApp : function() {
			<cathay:LocaleDisplay sysCode="DS" dateymFields="Q_REV_YM" dateFields="FINISH_DATE START_DATE END_DATE OCCUR_DATE"
				numberFields="FLOOR RENTAL DEPOSIT" var="localeDisplay" />
			PageUI.createPageWithAllBodySubElement("DSA60700", "覆審作業", "覆審建物謄本輸入", 0);
			
			$("btn_query").observe("click", buttons.doQuery); <%--查詢 --%>
			$("btn_insert").observe("click", buttons.doInsert); <%--新增 --%>
			$("btn_delete").observe("click", buttons.doDelete); <%--刪除 --%>
			$("btn_modify").observe("click", buttons.doModify); <%--修改 --%>
			$("btn_clear").observe("click", buttons.doClear); <%--清除 --%>
			$("btn_openDSA00200").observe("click", buttons.doOpenDSA00200); <%--建物謄本影像 --%>
			$("btn_addGridD").observe("click", buttons.doAddGridD); <%--新增-建物樓層資料 --%>
			$("btn_removeGridD").observe("click", buttons.doRemoveGridD); <%--移除-建物樓層資料 --%>
			$("btn_addGridE").observe("click", buttons.doAddGridE); <%--新增-建物所有權人 --%>
			$("btn_removeGridE").observe("click", buttons.doRemoveGridE); <%--移除-建物所有權人--%>

			$("Q_APPLY_ID").observe("change", actions.chgQ_APPLY_ID); <%--受理編號連動 --%>
			$("USE_STATUS").observe("change", actions.chgUSE_STATUS); <%--使用情形連動 --%>
			$("FINISH_DATE").observe("change", actions.calBUILD_AGE); <%--建築完成日連動 --%>
			$w('BUILD_NO1 BUILD_NO2').each(function(eleId){
				$(eleId).observe("blur", actions.toFixLength);
			});
			
			actions.initValidation();
			actions.initTableUI();
			actions.buttonAuth();
			
			if ('${APPLY_ID}' != "") {//接值
				$('Q_APPLY_ID').value = '${APPLY_ID}';
				$('Q_REV_YM').value = '${REV_YM}';
			} else { 
				//保留參數管理
				$('Q_APPLY_ID').value = CSRUtil.keepParamsManager.get('APPLY_ID');
				$('Q_REV_YM').value = CSRUtil.keepParamsManager.get('REV_YM');
			}			
			if($('Q_APPLY_ID').value){
				buttons.doQuery();
			}
			
			/*$("Q_APPLY_ID").setValue('${APPLY_ID}');
			$("Q_REV_YM").value = '${REV_YM}';
			var rtnMap = <c:out value="${rtnMap}" default="{}" escapeXml="false" />;
			if(Object.keys(rtnMap).length > 0){
				actions.setData(rtnMap);
			}*/
			
			displayMessage();

		}
	};	
};

</script>
</head>
<body>
	<form id="form1" name="form1" enctype="multipart/form-data" method="post" target="importFrame">
		<table id="blockA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="10%">受理編號</td>
				<td class="tbYellow2" width="15%">
					<input id='Q_APPLY_ID' name="Q_APPLY_ID" type="text" class="textBox2" size="15" maxlength="11" fieldName="受理編號" />
				</td>
				<td class="tbYellow" width="10%">覆審年月<font color="red">※例：11010</font></td>
				<td class="tbYellow2" width="15%">
					<input id="Q_REV_YM" name="Q_REV_YM" type="text" class="textBox2" size="7" maxlength="5" fieldName="覆審年月" />
				</td>
				<td class="tbYellow2" align="left" width="50%">
					<button id="btn_query" type="button" class="button">查詢</button>
					<button id="btn_openDSA00200" type="button" class="button">建物謄本影像</button>
				</td>
			</tr>
		</table>
		<div align="center">
			<button id="btn_insert" type="button" class="button">新增</button>
			<button id="btn_delete" type="button" class="button">刪除</button>
			<button id="btn_modify" type="button" class="button">修改</button>
			<button id="btn_clear" type="button" class="button">清除</button>
		</div>
		<table id='gridB' width='100%'></table>
		<table id="blockC1" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="15%">受理編號</td>
				<td class="tbYellow2" width="25%">
					<span id="APPLY_ID"></span>
				</td>
				<td class="tbYellow" width="15%">覆審鑑價進度</td>
				<td class="tbYellow2" width="45%">
					<span id="APPR_PROCESS_NM"></span>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">申請書門牌資料</td>
				<td class="tbYellow2" colspan="3">
					<%--[20241001]難字調整--%>
					<font color="red"><span id="GAGE_ADDR" style="font-family:'EUDC'"></span></font>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">房屋門牌號碼</td>
				<td class="tbYellow2" colspan="3">
					<%--[20241001]難字調整--%>
					<input id="ADDR_NO" name="ADDR_NO" type="text" size="80" class="textBox2" fieldName="房屋門牌號碼" alt="ch" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">建號(主建物建號)</td>
				<td class="tbYellow2">
					<input id="BUILD_NO1" name="BUILD_NO1" type="text" class="textBox2" maxLength="5" size="8" fieldName="建號(主建物建號)1" />
					-
					<input id="BUILD_NO2" name="BUILD_NO2" type="text" class="textBox2" maxLength="3" size="6" fieldName="建號(主建物建號)2" />
				</td>
				<td class="tbYellow">主建物判別碼</td>
				<td class="tbYellow2">
					<label class="box_label" for="MAIN_BUILD_1"><input type="radio" name="MAIN_BUILD" id="MAIN_BUILD_1" value="1">是</label>
					<label class="box_label" for="MAIN_BUILD_0"><input type="radio" name="MAIN_BUILD" id="MAIN_BUILD_0" value="0">否</label>
				</td>
			</tr>	
			<tr>
				<td class="tbYellow">主要建材</td>
				<td class="tbYellow2">
	              <select id="MATERIAL" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${MATERIAL_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow">主要用途</td>
				<td class="tbYellow2">
	              <select id="MAIN_USE" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${MAIN_USE_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>	
			<tr>
				<td class="tbYellow">總層數</td>
				<td class="tbYellow2">
					<input id="FLOOR" name="FLOOR" type="text" class="textBox2", fieldName="總層數" />
				</td>
				<td class="tbYellow">總面積</td>
				<td class="tbYellow2">
					<span id="BUILD_MEASURE">0</span>	
				</td>
			</tr>									
		</table>
		<table id='gridD' width='100%'></table>
		<div class="tbYellow" align="center">
			<button id="btn_addGridD" type="button" class="button">新增</button>
			<button id="btn_removeGridD" type="button" class="button">刪除</button>
		</div>
		<table id="blockC2" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="15%">建築完成日</td>
				<td class="tbYellow2" width="20%">
					<input id='FINISH_DATE' name="FINISH_DATE" type="text" class="textBox2" value="" fieldName="建築完成日" />
				</td>
				<td class="tbYellow" width="15%">屋齡</td>
				<td class="tbYellow2" width="15%">
					<span id="BUILD_AGE"></span>	
				</td>
				<td class="tbYellow" width="15%">原因發生日期</td>
				<td class="tbYellow2" width="20%">
					<input id='OCCUR_DATE' name="OCCUR_DATE" type="text" class="textBox2" value="" fieldName="原因發生日期" />
				</td>
			</tr>
		</table>
		<table id='gridE' width='100%'></table>
		<div class="tbYellow" align="center">
			<button id="btn_addGridE" type="button" class="button">新增</button>
			<button id="btn_removeGridE" type="button" class="button">刪除</button>
		</div>
		<table id="blockC3" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="15%">使用情形</td>
				<td class="tbYellow2" width="25%">
					<select id="USE_STATUS" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${USE_STATUS_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="15%">建築型態</td>
				<td class="tbYellow2" width="45%">
					<select id="BUILD_TYPE" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${BUILD_TYPE_LIST}">
							<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>
			<tr>
				<td class="tbYellow">月租金</td>
				<td class="tbYellow2">
					<input id='RENTAL' name="RENTAL" type="text" class="textBox2"fieldName="月租金" />
				</td>
				<td class="tbYellow">押金</td>
				<td class="tbYellow2">
					<input id='DEPOSIT' name="DEPOSIT" type="text" class="textBox2" fieldName="押金" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">租期</td>
				<td class="tbYellow2" colspan="3">
					<input id="START_DATE" name="START_DATE" type="text" class="textBox2" fieldName="租期起日" />
					~
					<input id="END_DATE" name="END_DATE" type="text" class="textBox2" fieldName="租期迄日" />
				</td>
			</tr>
			<tr>
				<td class="tbYellow">輸入人員</td>
				<td class="tbYellow2">
					<%--[20241001]難字調整--%>
					<span id="INPUT_NM" style="font-family:'EUDC'"></span>	
				</td>
				<td class="tbYellow">輸入日期</td>
				<td class="tbYellow2">
					<span id="INPUT_DATE"></span>	
				</td>
			</tr>	
		</table>
	</form>
</body>
</html>