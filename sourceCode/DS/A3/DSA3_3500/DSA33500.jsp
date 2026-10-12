<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA33500.jsp
功能：覆審件鑑價輸入、覆核
作者：巫國慧
完成：2020/01/30
[20241001] 修改件 CHROME瀏覽器難字調整 
[20250224] 修改件 新增承作分區與生活圈相關，調整修改與呈核存入資料
[20250317] 調整生活圈儲存、預帶等方式
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
<!-- 目前系統常用的表格工具 -->
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/JavaScript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/RPTUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/suggest.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/InputUtility.js"></script>

<script type="text/JavaScript">
Event.observe(window, 'load', new DSA33500().initApp);

function DSA33500(){
	
	var valid,valid2;
    var grid,gridD,gridF,gridG;
	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_3500/');
	var recordMap = {}; <%-- 紀錄radio選取的單筆資料 --%>
	var IS_LOSS_LIST = <c:out value='${IS_LOSS_LIST}' escapeXml='false' default='{}'/>; <%-- 是否減損 --%>
	var IS_THERE_RPT_LIST = <c:out value='${IS_THERE_RPT_LIST}' escapeXml='false' default='{}'/>; <%-- 是否出具報告 --%>
	
	
	<%-- 綁定按鈕 --%>
	function buttonAuth(){
		var authButtons = {
			B0004:'btn_update', <%-- 修正 --%>
			B0073:'btn_confirm', <%-- 呈核 --%>
			B0085:'btn_cancel', <%-- 取消呈核 --%>
			B0117:"btn_captainConfirm", <%-- 組長覆核 --%>
			B0018:"btn_captainReject" <%-- 組長退回 --%>
		};
		
		<dz:grantButtons FUNC_ID="DSA33500" ignored="false"/>	
	};
	 
	<%-- 畫面檢核 --%>
	function initValidation(){	
		valid = new Validation('form1');
		valid2 = new Validation('CDAreaDiv');
		valid.define( 'required' , [{ id: 'APPR_GROUP_Q', errMsg : '請選擇鑑價組' }]);
		valid.define( 'required' , [{ id: 'REV_YM_Q', errMsg : '請輸入覆審年月' }]);
	};
	
	var actions = {
		<%-- 取得查詢條件 --%>
		getQueryMap : function(){
			return {
				'REV_YM':$('REV_YM_Q').value, <%-- 覆審年月(取民國年月) --%>
				'APPR_GROUP':$F('APPR_GROUP_Q'), <%-- 鑑價組 --%>
				'APPR_PROCESS':$F('APPR_PROCESS_Q'), <%-- 覆審鑑價進度 --%>
				'APPR_ID':$F('APPR_ID_Q') <%-- 鑑價人員 --%>
			};
		},
		<%-- 取得初始查詢條件 --%>
		getInitReqMap : function(){
			var reqMap = {};
			$w('LOAN_ID APPLY_ID REFER_ID REV_YM REV_DEPT_CODE REV_KIND REV_TYPE').each(function(id){
				reqMap[id] = $F('init_'+id);
			});
			return reqMap;
		},
		<%-- 建立超連結 --%>
		doBuildLink : function(linkTo, value, tempOP, inputName, i){
			var link = new Element('a',{'href':'javascript:void(0);',inputName:value, 'linkTo':linkTo, 'tempOP':tempOP, 'id':inputName+i}).update(value);
			link.observe('click', function(){
				popupWin.windowOpen( '${dispatcher}/'+this.getAttribute('linkTo')+'/prompt' ,
				{
					'parameters': {'APPLY_ID': value, 'OP': tempOP},
					'fullScreen': false,
					'attributes': {'resizable': 'yes'}
				});
			});
			return link;
		},
		<%-- 開啟影像元件 --%>
		doLink_DSA00200 : function(){
			var applyId = this.getAttribute('APPLY_ID');
			popupWin.windowOpen('${dispatcher}/DSA0_0200/prompt', { 	
					'parameters': {'APPLY_ID': applyId},
					'fullScreen': false,
					'attributes': {'resizable': 'yes'},
					'windowName': 'DSA33500' <%--視窗名稱，只會覆掉相同名稱的視窗--%>
				});
		},
		<%-- 塞值(C、D區塊) --%>
		setField_CArea : function(btnCalculateIsDisable){
			
			$('IMG_INPUT_DATE').update(recordMap['IMG_INPUT_DATE'] ? Date.toROC(recordMap['IMG_INPUT_DATE']) : '');
			$('APPLY_ID').update(recordMap['APPLY_ID'] || '');
			<%--[20250225]增-SUBMKT_NAME,SUBMKT_ID,SUBMKT_VERSION,AREA_CODE_930318,AREA_CODE_MATCH_LEVEL--%>
			$('AREA_CODE_930318').setValue(recordMap['AREA_CODE_930318'] || '');
			$('AREA_CODE_930318_NM').update(recordMap['AREA_CODE_930318_NM'] + '區' || '');
			if(recordMap['loan_rest_list_exist']){<%--[20250317]調整生活圈預帶方式--%>
				$('SUBMKT_NAME').enable()
				$('SUBMKT_NAME').value = recordMap['SUBMKT_NAME'] || '';
				$('SUBMKT_ID').setValue(recordMap['SUBMKT_ID'] || '');
				$('SUBMKT_VERSION').setValue(recordMap['SUBMKT_VERSION'] || '');
				$('AREA_CODE_MATCH_LEVEL').setValue(recordMap['AREA_CODE_MATCH_LEVEL'] || '');
			} else {
				$('SUBMKT_NAME').disable();
			}
			$('APPR_PROCESS_NM').update(recordMap['APPR_PROCESS_NM'] || '');
			$('REV_LEVEL_NM').update(recordMap['REV_LEVEL_NM'] || '');
			$('APPR_DATE').update(recordMap['APPR_DATE'] ? Date.toROC(recordMap['APPR_DATE']) : '');
			$('REV_YM').update(recordMap['REV_YM'] || '');
			$('APPR_NM').update(recordMap['APPR_NM'] || '');
			$('PRE_REV_YM').update(recordMap['PRE_REV_YM'] || '');
			$('PRE_APPR_NM').update(recordMap['PRE_APPR_NM'] || '');
			$('PRE_TOTAL_PRICE').update(localeDisplay.formatNumber(recordMap['PRE_TOTAL_PRICE']));
			$('APPR_APPLY_ID').update(recordMap['APPR_APPLY_ID'] || '');
			$('USE_FOR_NM').update(recordMap['USE_FOR_NM'] || '');
			$('ADDR_NO').update(recordMap['ADDR_NO'] || '');
			$('ORI_APPR_NM').update(recordMap['ORI_APPR_NM'] || '');
			$('ORI_CAPT_NM').update(recordMap['ORI_CAPT_NM'] || '');
			$('ORI_APPR_DATE').update(recordMap['ORI_APPR_DATE'] ? Date.toROC(recordMap['ORI_APPR_DATE']) : '');
			$('ORI_TOTAL_PRICE').update(localeDisplay.formatNumber(recordMap['ORI_TOTAL_PRICE']));
			
			if(!recordMap || Object.keys(recordMap).length == 0){
				gridD.load([]);
				gridF.load([]);
				gridG.load([]);
				return;
			}
			$('imageFieldDiv').update('');
			var link = new Element('a', {'href':'javascript:void(0);','id':'imageField','APPLY_ID':recordMap.APPLY_ID || ''}).update('土地、建物謄本影像(新版)');
			link.observe('click', actions.doLink_DSA00200); <%-- 影像資料 --%>
			$('imageFieldDiv').insert(link);
			var rtnList = [recordMap];
			gridD.load(rtnList);
			gridF.load(rtnList);
			gridG.load(rtnList);
			if('2'==$F('init_OP') && parseInt(recordMap.APPR_PROCESS, 10)>=40){
				gridG.show();
			}else{
				gridG.hide();
			}
			$$('#form1 textarea').each(function(elm){
				var textAreaId = elm.id;
				InputUtility.lengthLimit.add(textAreaId, 2000, true); <%-- 限制2000字 --%>
				$(textAreaId).doLengthLimit(); <%-- 偵測textarea的字數變動 --%>
			});
			autoFormatToNumber();
		},
		<%-- 按鈕控制 --%>
		buttonControl : function(){
			<%--[20250225]增-SUBMKT_NAME--%>
			if('1'==$F('init_OP')){
				$('btn_update').show(); <%-- 修正 --%>
				$('btn_confirm').show(); <%-- 呈核 --%>
				$('btn_cancel').show(); <%-- 取消呈核 --%>
				$('btn_captainConfirm').hide(); <%-- 組長覆核 --%>
				$('btn_captainReject').hide(); <%-- 組長退回 --%>
				$('SUBMKT_NAME').enable();
			}else{
				$('btn_update').hide();
				$('btn_confirm').hide();
				$('btn_cancel').hide();
				$('btn_captainConfirm').show();
				$('btn_captainReject').show();
				$('SUBMKT_NAME').disable();
			}
		},
		<%-- 重製檢核2(C區塊相關檢核) --%>
		resetValid2 : function(strName){
			valid.reset();
			valid2.clear();
			valid2.reset();
			<%-- update && calculate --%>
			$('CDAreaDiv').select('input[name="LAND_AVG_PRICE"]','input[name="BUILD_AVG_PRICE"]','input[name="PARK_AMT_PRICE"]'
					).each(function(elm){
				var inputId = elm.id
				valid2.define( 'validate-number' , [{ 'id':inputId }]); <%-- 只能輸入數字 --%>
				valid2.define( 'required' , [{ 'id':inputId, errMsg:'請輸入'+elm.getAttribute('title') }]); <%-- 必輸 --%>
			});
			if('calculate' == strName){
				return;
			}
			<%-- update --%>
			$('CDAreaDiv').select('input[name="TOTAL_PRICE"]','input[name="PARK_SPACE"]','input[name="PARK_NUM"]').each(function(elm){
				var inputId = elm.id
				valid2.define( 'validate-number' , [{ 'id':inputId }]); <%-- 只能輸入數字 --%>
				valid2.define( 'required' , [{ 'id':inputId, errMsg:'請輸入'+elm.getAttribute('title') }]); <%-- 必輸 --%>
			});
			$('CDAreaDiv').select('select').each(function(elm){
				valid2.define( 'required' , [{ 'id':elm.id, errMsg:'請選擇'+elm.getAttribute('title') }]); <%-- 必輸 --%>
			});
		},
		<%-- 限制整數長度 --%>
		limitIntLength : function(inputId, limitLength){
			var input = $(inputId)
			var value = $F(inputId);
			var valueLength = value.length;
			if(!value || value.length<=limitLength){
				return;
			}
			var indexOfPoint = value.indexOf('.');
			var tempValue = value.substring(0,limitLength);
			if((indexOfPoint==-1)){
				input.setValue(tempValue);
			}else if(indexOfPoint>limitLength){
				tempValue += value.substring(indexOfPoint, valueLength);
				input.setValue(tempValue);
			}
		},
		<%-- 建立輸入欄位 --%>
		buildInput : function(value, i, inputName, chName, maxLength){
			var param = {'id':inputName+i,'name':inputName,'title':chName,'maxLength':maxLength,'type':'text','class':'textBox2'};
			var input = new Element('input', param).setValue(value || '');
			input.observe('change', function(){recordMap[this.name] = $F(this.id)});
			return input;
		},
		<%-- 建立數值輸入欄位 --%>
		buildNumberInput : function(value, i, inputName, chName, pattern, intLength){
			if('1'==$F('init_OP')){
				var param = {'pattern':pattern,'id':inputName+i,'name':inputName,'title':chName,'fieldName':chName,'maxLength':'20','type':'text','class':'textBox2','datatype':'number','intLength':intLength};
				var input = new Element('input', param).setValue(value || '');
				input.observe('blur', function(){recordMap[this.name] = $F(this.id)});
				input.observe('keyup', function(){actions.limitIntLength(this.id, this.getAttribute('intLength'))});
				return input;
			}else{
				return value || '';
			}
		},
		<%-- 建立下拉選單 --%>
		buildSelect : function(name, title, value, i){
			var select = new Element('select', {'id':name+i, 'name':name, 'title':title, 'fieldName':title, 'class':'textBox2'});
			select.add(new Option('', '')); <%-- 預設顯示空字串(VALUE="") --%>
			if('IS_LOSS' == name){ <%-- 是否減損 --%>
				for(key in IS_LOSS_LIST){
					select.add(new Option(IS_LOSS_LIST[key], key));
				}
			}else{ <%-- 是否出具減損報告 --%>
				for(key in IS_THERE_RPT_LIST)
				select.add(new Option(IS_THERE_RPT_LIST[key], key));
			}
			select.setValue(value || '');
			select.observe('change', function(){recordMap[this.name] = $F(this.id)})
			if('2'==$F('init_OP')){
				select.disable();
			}
			return select;
		},
		<%-- 日期格式化成民國年月日(YYY/MM/DD) --%>
		simpleDateFormatTW : function(value){
			if(!value){
				return '';
			}
			var df = new SimpleDateFormat('yyy/MM/dd', SimpleDateFormat.TW);
			return df.format(value);
		},
		<%-- 紀錄的選取資料變空值 --%>
		doRecordMapEmpty : function(){
			recordMap = {};
			actions.setField_CArea(); <%-- C、D區塊塞值 --%>
			$('CDAreaDiv').hide(); <%-- C、D區塊隱藏 --%>
		},
		<%-- 方法成功後指定欄位顯示及塞值 --%>
		doActionSuccess : function(resp){
			$('CDAreaDiv').show(); <%-- C、D區塊顯示 --%>
			recordMap = resp.rtnMap || {};
			recordMap['btnCalculateIsDisable'] = resp.btnCalculateIsDisable;
			actions.setField_CArea(); <%-- C、D區塊塞值 --%>
		},
		<%-- 取得鑑價人員 --%>
		doGetAPPR_ID_LIST : function(){
			if(''==$('APPR_GROUP_Q').value){
				return;
			}
			var dataMap = {};
			dataMap.APPR_GROUP = $('APPR_GROUP_Q').value;
			
			ajaxRequest.post(
				'getAPPR_ID_LIST', {'inputMap':Object.toJSON(dataMap)},
				function(resp){	
					var optionList = resp.APPR_ID_LIST ? resp.APPR_ID_LIST:[];
					$('APPR_ID_Q').length = 1;
					for(var i = 0; i < optionList.length; i++){
						$('APPR_ID_Q').options.add(new Option(optionList[i]['NAME'], optionList[i]['ID']));
					}
				}
			);
		},
		getAREA_CODE: function(rec){ <%-- [20250225]取承作分區 --%>
			ajaxRequest.post('getAREA_CODE', {'reqMap':Object.toJSON(rec)},
				function(resp){	
					var rtnMap = resp.rtnMap;
					$('AREA_CODE_930318').setValue(rtnMap.AREA_CODE || '');
					$('AREA_CODE_930318_NM').update(rtnMap.AREA_CODE_NM + '區' || '');
					$('AREA_CODE_MATCH_LEVEL').setValue(rtnMap.MATCH_LEVEL || '');
				}
			);
		},
		getUpdateData: function(){ <%-- [20250225]取A290更新資料 --%>
			var updateMap = Object.clone(recordMap);
			<%--[20250317]調整生活圈儲存取值方法--%>
			var AREA_CODE_930318 = $F('AREA_CODE_930318');
			updateMap.AREA_CODE_930318 = AREA_CODE_930318;
			var SUBMKT_ID = $F('SUBMKT_ID');
			if(''==SUBMKT_ID && ''!=AREA_CODE_930318){
				return updateMap;
			}
			updateMap.SUBMKT_NAME = $F('SUBMKT_NAME');
			updateMap.SUBMKT_ID = SUBMKT_ID;
			updateMap.SUBMKT_VERSION = $F('SUBMKT_VERSION');
			updateMap.AREA_CODE_MATCH_LEVEL = $F('AREA_CODE_MATCH_LEVEL');
			return updateMap;
		}
	};
	
	var buttons = {
	    <%-- 查詢案件明細 --%>
		doQueryDetail : function(record){
			var queryDetailMap = Object.toJSON(record);
			$('queryDetailMap').setValue(queryDetailMap);
			valid.reset();
			valid2.clear();
			var APPR_APPLY_ID = record.APPR_APPLY_ID;
			var btnCalculateIsDisable; 
			if(!APPR_APPLY_ID){
				alert('本件未取得原鑑價資料，需自行輸入計算，請注意。');
				btnCalculateIsDisable = 'true';
			}
			ajaxRequest.post(
				'queryDetail', { 'reqMap':$F('queryDetailMap')},
				function(resp){
					resp['btnCalculateIsDisable'] = btnCalculateIsDisable;
					actions.doActionSuccess(resp); <%-- 方法成功後指定欄位顯示及塞值 --%>
				}
				, function(resp){
					actions.doRecordMapEmpty(); <%-- 紀錄的選取資料變空值 --%>
				}
			);
	    },
		<%-- 查詢 --%>
		doQuery : function(){
			var reqMap;
			if($F('init_APPLY_ID') && !$F('op1query')){
				reqMap = Object.toJSON(actions.getInitReqMap()); <%-- 取得初始查詢條件 --%>
			}else{
				$('op1query').setValue('Y');
				valid.reset();
				valid2.clear();
				if(!valid.validate()){
					return;
				}
				reqMap = Object.toJSON(actions.getQueryMap()); <%-- 取得查詢條件 --%>
			}
			ajaxRequest.post( 
				'query', {'reqMap':reqMap},
				function(resp){	
					grid.load(resp.rtnList || []);
				}
				,function(resp){
					grid.load([]);
				}
			);
			actions.doRecordMapEmpty(); <%-- 紀錄的選取資料變空值 --%>
	    },
	    <%-- 清除(初始化) --%>
		doClear : function(){
			var param = {};
			$w('OP LOAN_ID APPLY_ID REFER_ID REV_YM REV_DEPT_CODE REV_KIND REV_TYPE').each(function(id){
				param[id] = $F('init_'+id);
			});
			var link_form = $('link_form');
			for(var key in param){
				var input = new Element('input');
				input.setAttribute('type','hidden');
				input.setAttribute('name', key);
				input.setAttribute('value', param[key]);
				link_form.insert(input); 
			}
						
			link_form.action = '${dispatcher}/DSA3_3500/prompt';
			link_form.submit();
		},
		<%-- 列印 --%>
		doPrint : function(){
			if(grid.getAllRecords().length == 0){
				alert("請先執行查詢");  
				return;
			}
			var records = grid.getCheckedRecord();
			var recordsLength = records.length;
			if(recordsLength == 0){
				alert("請先選取要列印的資料");  
				return;
			}
			var queryData = [];
			for(var i =0; i< recordsLength; i++) {
				queryData.push({
					'LOAN_ID':records[i]['LOAN_ID']
					,'APPLY_ID':records[i]['APPLY_ID']
					,'REFER_ID':records[i]['REFER_ID']
					,'REV_YM':records[i]['REV_YM']
					,'REV_DEPT_CODE':records[i]['REV_DEPT_CODE']
					,'REV_KIND':records[i]['REV_KIND']
					,'APPR_APPLY_ID':records[i]['APPR_APPLY_ID']
				});			
			}
			
			/*window.open("", "DSA3_3500", "top=50, left=50, toolbar=no, resizable=yes, location=0, status=0, scrollbars=1, titlebar=0, width=800, height=600");
			
			var link_form = $('link_form');
			var input = new Element('input', {'type':'hidden', 'name':'queryData', 'value':Object.toJSON(queryData)});
			link_form.insert(input); 
			link_form.target = 'DSA3_3500';	
			link_form.action = '${dispatcher}/DSA3_3500/print';
			link_form.submit();*/
			var printData = {
				'queryData': Object.toJSON(queryData)
			};
			RPTUtil.executePrintByLink('print', printData, true);
		},
		<%-- 修正 --%>
		doUpdate : function(){
			actions.resetValid2('update'); <%-- 重製檢核2(C區塊相關檢核) --%>
			if(!valid2.validate()){
				return;
			}
			var reqMap = actions.getUpdateData();
			if(reqMap['loan_rest_list_exist']){ <%--[20250317]調整生活圈輸入判斷--%>
				if(''==reqMap.SUBMKT_ID && ''==reqMap.AREA_CODE_930318){
					alert("請選擇生活圈名稱");
					return;
				}
			}
			ajaxRequest.post(
				'update', {'reqMap':Object.toJSON(reqMap), 'queryDetailMap':$F('queryDetailMap')},
				function(resp){	
					actions.doActionSuccess(resp); <%-- 方法成功後指定欄位顯示及塞值 --%>
				}
			);
		},
		<%-- 呈核 --%>
		doConfirm : function(){
			actions.resetValid2('confirm'); <%-- 重製檢核2(C區塊相關檢核) --%>
			if(!valid2.validate()){
				return;
			}
			var reqMap = actions.getUpdateData();
			if(reqMap['loan_rest_list_exist']){<%--[20250317]調整生活圈輸入判斷--%>
				if(''==reqMap.SUBMKT_ID && ''==reqMap.AREA_CODE_930318){
					alert("請選擇生活圈名稱");
					return;
				}
			}
			ajaxRequest.post(
				'confirm', {'reqMap':Object.toJSON(reqMap), 'queryDetailMap':$F('queryDetailMap')},
				function(resp){	
					actions.doActionSuccess(resp); <%-- 方法成功後指定欄位顯示及塞值 --%>
				}
			);
		},
		<%-- 取消呈核 --%>
		doCancel : function(){
			ajaxRequest.post(
				'cancel', {'reqMap':Object.toJSON(recordMap), 'queryDetailMap':$F('queryDetailMap')},
				function(resp){	
					actions.doActionSuccess(resp); <%-- 方法成功後指定欄位顯示及塞值 --%>
				}
			);
		},
		<%-- 組長覆核 --%>
		doCaptainConfirm : function(){
			actions.resetValid2('captainConfirm'); <%-- 重製檢核2(C區塊相關檢核) --%>
			if(!valid2.validate()){
				return;
			}
			ajaxRequest.post(
				'captainConfirm', {'reqMap':Object.toJSON(recordMap), 'queryDetailMap':$F('queryDetailMap')},
				function(resp){	
					actions.doActionSuccess(resp); <%-- 方法成功後指定欄位顯示及塞值 --%>
				}
			);
		},
		<%-- 組長退回 --%>
		doCaptainReject : function(){
			ajaxRequest.post(
				'captainReject', {'reqMap':Object.toJSON(recordMap), 'queryDetailMap':$F('queryDetailMap')},
				function(resp){	
					actions.doActionSuccess(resp); <%-- 方法成功後指定欄位顯示及塞值 --%>
				}
			);
		},
		<%-- 計算 --%>
		doCalculate : function(){
			actions.resetValid2('calculate'); <%-- 重製檢核2(C區塊相關檢核) --%>
			if(!valid2.validate()){
				return;
			}
			ajaxRequest.post( 
				'calculate', {'reqMap':Object.toJSON(recordMap), 'OP':$F('init_OP')},
				function(resp){
					recordMap['TOTAL_PRICE'] = resp.TOTAL_PRICE || '';
					gridD.load([recordMap]);
				}
			);
		}
    };

	return{
		initApp : function(){
			<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateymFields='REV_YM_Q'/>
			PageUI.createPageWithAllBodySubElement(
				"DSA33500",
				"鑑價作業",
				"${displayName}"
			);
			<%--[20241001]難字調整--%>
			grid = new TableUI({
                table: $("grid1"), allSortable: true, pageSize: 5, whenDataNull:'', 
				autoCheckBox:{
					text:'列印選取', 
					type:'checkBox',
					isSelectAll:true,
					insertPosition:1
				},
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:[	
					{header:"選取"
						,render:function(record, value, i){
							var radio = new Element('input', {'id':'grid1Radio'+i, 'name':'grid1Radio', 'type':'radio', 'class':'input'});
							radio.observe('click', function(){
								buttons.doQueryDetail(record); <%-- 查詢案件明細 --%>
							});
							return radio;
						}
					},
					{header:"受理編號", key:'APPLY_ID'},
					{header:"鑑價報告編號", key:'APPR_APPLY_ID'
						,render:function(record, value, i){
							if(!value && value!='0'){
								return '';
							}
							var link;
							if (value.substring(3,5)=='@A' || value.substring(3,5)=='@I' || value.substring(3,5)=='@J') {
								link = actions.doBuildLink('DSA3_0600', value, '', 'APPLY_ID', i); <%-- 連結'土建融鑑價報告' --%>
			 				} else if (value.substring(3,5)=='@B' || value.substring(3,5)=='@U' || value.substring(3,5)=='@V') {
			 					link = actions.doBuildLink('DSA3_0700', value, '', 'APPLY_ID', i); <%-- 連結'整批件鑑價報告' --%>
			 				} else {
			 					link = actions.doBuildLink('DSA3_0500', value, '', 'APPLY_ID', i); <%-- 連結'一般件鑑價報告' --%>
			 				}
							return link;
						}
					},
					{header:"分級", key:'REV_LEVEL_NM'},
					{header:"本金餘額", key:'TOTAL_REMAIN_AMT', sortRule: 'number'},
					{header:"原鑑價人員", key:'ORI_APPR_NM', style:"font-family:'EUDC'"},
					{header:"原鑑價組長", key:'ORI_CAPT_NM', style:"font-family:'EUDC'"},
					{header:"覆審年月", key:'REV_YM'},
					{header:"鑑價組", key:'APPR_GROUP_NM'},
					{header:"覆審鑑價員", key:'APPR_NM', style:"font-family:'EUDC'"},
					{header:"覆審鑑價進度", key:'APPR_PROCESS_NM'},
					{header:"派件日期", key:'APPR_ASSIGN_DATE', sortRule: 'date'},
					{header:"覆審科別", key:'REV_DEPT_CODE_NM'},
					{header:"覆審人員", key:'REV_NM', style:"font-family:'EUDC'"},
				]
			});
			gridD = new TableUI({
                table: $("grid2"),
                pageSize: 0,
				column:[	
					[
						{header:"土地總面積", key:'LAND_SPACE', sortRule:'number'},
						{header:"建物總面積", key:'BUILD_SPACE', sortRule:'number'},
						{header:"車位總面積", key:'PARK_SPACE', sortRule:'number'
							,render:function(record, value, i){
								return actions.buildNumberInput(value, i, 'PARK_SPACE', '車位總面積', '#,###.###', 8);
							}
						},
						{header:"建物屋齡", key:'BUILD_AGE', sortRule:'number'},
						{header:"減損報告編號", key:'LOSS_RPT_NO'
							,render:function(record, value, i){
								var link;
								//輸入畫面連結到一般件鑑價輸入
								if('1'==$F('init_OP')){
									link = !value ? '' : actions.doBuildLink('DSA3_0500', value, '1', 'LOSS_RPT_NO', i); <%-- 連結'一般件鑑價報告' --%>;
								}else{
									link = !value ? '' : actions.doBuildLink('DSA3_0500', value, '', 'LOSS_RPT_NO', i); <%-- 連結'一般件鑑價報告' --%>;
								}
								return link;
							}
						},
						{header:"是否出具減損報告", key:'IS_THERE_RPT'
							,render:function(record, value, i){
								var div = new Element('div',{'id':'IS_THERE_RPT_DIV'+i});
								div.insert(actions.buildSelect('IS_THERE_RPT', '是否出具報告', value, i));
								return div;
							}
						}
					],[
						{header:"地價", key:'LAND_AVG_PRICE', sortRule:'number'
							,render:function(record, value, i){
								return actions.buildNumberInput(value, i, 'LAND_AVG_PRICE', '地價', '#,###.##', 8);
							}
						},
						{header:"單價/造價", key:'BUILD_AVG_PRICE', sortRule:'number'
							,render:function(record, value, i){
								return actions.buildNumberInput(value, i, 'BUILD_AVG_PRICE', '單價', '#,###.##', 8);
							}
						},
						{header:"車位總價", key:'PARK_AMT_PRICE', sortRule:'number'
							,render:function(record, value, i){
								return actions.buildNumberInput(value, i, 'PARK_AMT_PRICE', '車位總價', '#,###.##', 8);
							}
						},
						{header:"車位總數", key:'PARK_NUM', sortRule:'number'
							,render:function(record, value, i){
								return actions.buildNumberInput(value, i, 'PARK_NUM', '車位總數', '#,###', 3);
							}
						},
						{header:"覆審總值", key:'TOTAL_PRICE'
							,render:function(record, value, i){
								var div = new Element('div',{'id':'TOTAL_PRICE_DIV'+i});
								div.insert(actions.buildNumberInput(value, i, 'TOTAL_PRICE', '覆審總值', '#,###.##', 10));
								var btn = new Element('button',{'id':'btn_calculate'+i, 'type':'button', 'class':'button', 'record_i':i, 'strName':'c'}).update('C');
								btn.observe('click', buttons.doCalculate); <%-- 計算 --%>
								if('true' == recordMap.btnCalculateIsDisable){
									btn.disable();
								}
								div.insert(btn);
								return div
							}
						},
						{header:"是否減損", key:'IS_LOSS'
							,render:function(record, value, i){
								return actions.buildSelect('IS_LOSS', '是否減損', value, i);
							}
						}
					]
				]
			});
			gridF = new TableUI({
                table: $("grid3"),
                pageSize: 0,
				column:[
					{header:"補充說明", key:'APPR_OTHER_DESC'
						,render:function(record, value, i){
							if('1'==$F('init_OP')){
								var textArea = new Element('textArea',{'id':'APPR_OTHER_DESC'+i, 'name':'APPR_OTHER_DESC','rows':'8', 'cols':'150'}).setValue(value||'');
								textArea.observe('change', function(){recordMap[this.name] = $F(this.id)});
								return textArea;
							}else{
								return value || '';
							}
						}
					}
				]
			});
			gridG = new TableUI({
                table: $("grid4"),
                pageSize: 0,
    			afterLoad: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
    			pageChange: function() {
    				if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
    			},
				column:[	
					{header:"覆核組長", key:'APPR_CAPT_NM', style:"font-family:'EUDC'"},
					{header:"日期", key:'APPR_CAPT_DATE'
						,render:function(record, value, i){
							return actions.simpleDateFormatTW(value); <%-- 日期格式化成民國年月日(YYY/MM/DD) --%>
						}
					},
					{header:"覆核主管", key:'APPR_BOSS_NM', style:"font-family:'EUDC'"},
					{header:"日期", key:'APPR_BOSS_DATE'
						,render:function(record, value, i){
							return actions.simpleDateFormatTW(value); <%-- 日期格式化成民國年月日(YYY/MM/DD) --%>
						}
					}
				]
			});
			
			//取得「鑑價人員」下拉選單			
			$('APPR_GROUP_Q').observe('change',function(event){
					actions.doGetAPPR_ID_LIST();
				}
			);
			
			<%-- 按鈕事件監聽 --%>
			$('btn_query').observe('click', buttons.doQuery); <%-- 查詢 --%>
			$('btn_clear').observe('click', buttons.doClear); <%-- 清除 --%>
			$('btn_print').observe('click', buttons.doPrint); <%-- 列印 --%>
			$('btn_update').observe('click', buttons.doUpdate); <%-- 修正 --%>
			$('btn_confirm').observe('click', buttons.doConfirm); <%-- 呈核 --%>
			$('btn_cancel').observe('click', buttons.doCancel); <%-- 取消呈核 --%>
			$('btn_captainConfirm').observe('click', buttons.doCaptainConfirm); <%-- 組長覆核 --%>
			$('btn_captainReject').observe('click', buttons.doCaptainReject); <%-- 組長退回 --%>
			<%-- [20250224]建議清單-生活圈名稱 --%>
			Suggest.add("SUBMKT_NAME", Suggest.URL, "${dispatcher}/DSA3_3500/getSUBMKT", {	
				option_key: "NAME",
				remark_key: "SUBMKT_ID",
				noCookies: true,
				startLength: 2,
				callBackFunc: function(node, rec){
					$('AREA_CODE_930318').setValue('');
					$('AREA_CODE_930318_NM').update('');
					$('AREA_CODE_MATCH_LEVEL').setValue('');
					if(!rec){ 
						$('SUBMKT_ID').setValue('');
						$('SUBMKT_VERSION').setValue('');
						return;
					}
					$('SUBMKT_ID').setValue(rec.SUBMKT_ID || '');
					$('SUBMKT_VERSION').setValue(rec.VERSION || '');
					actions.getAREA_CODE(rec);
				}
			});
			
			buttonAuth(); <%-- 按鈕綁定 --%>
			initValidation();
			displayMessage();
			
			actions.buttonControl(); <%-- 按鈕控制 --%>
			$('CDAreaDiv').hide(); <%-- 初始無資料，隱藏區塊 --%>
			
			if($F('init_APPLY_ID')){ <%-- 其他頁面連結過來 --%>
				ajaxRequest.setSynchronous(true);
				buttons.doQuery();
				ajaxRequest.setSynchronous(false);
				var grid1Radio1 = $('grid1Radio1');
				if(grid.getAllRecords().length>0 && grid1Radio1){
					grid1Radio1.click();
				}
			}
			
			<%-- 下一頁回來時 --%>
			var LP_JSON = CSRUtil.isBackLink('form1');
			if(LP_JSON){
				var obj = LP_JSON.BQ_ARG;
				$('APPR_GROUP_Q').setValue(obj.APPR_GROUP_Q || '');
				$('APPR_ID_Q').setValue(obj.APPR_ID_Q || '');
				$('REV_YM_Q').setValue(obj.REV_YM_Q || '');
				$('APPR_PROCESS_Q').setValue(obj.APPR_PROCESS_Q || '');
				buttons.doQuery(); <%-- 執行查詢動作 --%>
			}
		}	
		
	};
}
</script>
</head>
<body>
<form name='form1' id='form1'>
<input id='init_OP' name='init_OP' type='hidden' value='${OP}'/>
<input id='init_LOAN_ID' name='init_LOAN_ID' type='hidden' value='${LOAN_ID}'/> <%-- 貸款帳號 --%>
<input id='init_APPLY_ID' name='init_APPLY_ID' type='hidden' value='${APPLY_ID}'/> <%-- 受理編號 --%>
<input id='init_REFER_ID' name='init_REFER_ID' type='hidden' value='${REFER_ID}'/> <%-- 原貸帳號 --%>
<input id='init_REV_YM' name='init_REV_YM' type='hidden' value='${REV_YM}'/> <%-- 覆審年月 --%>
<input id='init_REV_DEPT_CODE' name='init_REV_DEPT_CODE' type='hidden' value='${REV_DEPT_CODE}'/> <%-- 覆審科別 --%>
<input id='init_REV_KIND' name='init_REV_KIND' type='hidden' value='${REV_KIND}'/> <%-- 案件種類 --%>
<input id='init_REV_TYPE' name='init_REV_TYPE' type='hidden' value='${REV_TYPE}'/> <%-- 覆審類別 --%>
<input id='queryData' name='queryData' type='hidden'/> <%-- 查詢資料 --%>
<input id='queryDetailMap' name='queryDetailMap' type='hidden'/> <%-- queryDetai查詢條件 --%>
<input id='op1query' name='op1query' type='hidden'/> <%-- 是否已執行一般的條件查詢 --%>
<%-- A區 --%>
<table width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">鑑價組</td>
		<td class="tbYellow2" width="15%">
			<select title="鑑價組" id="APPR_GROUP_Q" name="APPR_GROUP_Q" class="textBox2" fieldName="鑑價組">
				<option value="">全部</option>
				<c:forEach items="${APPR_GROUP_LIST}" var="map">
					<option value="${map.key}" />${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow" width="10%">覆審鑑價進度</td>
		<td class="tbYellow2"  width="40%">
			<select title="覆審鑑價進度" id="APPR_PROCESS_Q" name="APPR_PROCESS_Q" class="textBox2" fieldName="覆審鑑價進度">
				<option value="">全部</option>
				<c:forEach items="${APPR_PROCESS_LIST}" var="map">
					<option value="${map.key}" />${map.value}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow2" align="center" rowspan="2" width="25%">
			<button id="btn_query" type="button" class="button">查詢</button>
			<button id="btn_print" type="button" class="button">列印</button>
			<button id="btn_clear" type="button" class="button">清除</button>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">鑑價人員</td>
		<td class="tbYellow2">
			<%--[20241001]難字調整--%>
			<select title="鑑價人員" id="APPR_ID_Q" name="APPR_ID_Q" class="textBox2" fieldName="鑑價人員" alt="ch">
				<option value="">全部</option>
				<c:forEach items="${APPR_ID_LIST}" var="map">
					<option value="${map.ID}" <c:if test="${map.ID eq LOGIN_ID}">selected</c:if>/>${map.NAME}</option>
				</c:forEach>
			</select>
		</td>
		<td class="tbYellow">覆審年月<font color="red">※例：11010</font></td>
		<td class="tbYellow2">
			<input title="覆審年月" id="REV_YM_Q" name="REV_YM_Q" class="textBox2" fieldName="覆審年月"/>
		</td>
	</tr>
</table>
<%-- B區 --%>
<table id="grid1" class="grid"></table>
<div id='CDAreaDiv'>
<%-- C區 --%>
<table width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow" width="10%">影像輸入日期</td>
		<td class="tbYellow2" width="15%">
			<span id='IMG_INPUT_DATE'></span>
		</td>
		<td class="tbYellow" width="10%">影像</td>
		<td class="tbYellow2" width="65%">
			<div id='imageFieldDiv'></div>
		</td>
	</tr>
</table>
<table width="100%" class="tbBox2">
	<tr>
		<td class="tbYellow0" width="100%" colspan="8" align=middle>
			<strong>案件資料</strong>
		</td>
	</tr>
	<tr>
		<td class="tbYellow" width="10%">受理編號</td>
		<td class="tbYellow2" width="15%">
			<span id='APPLY_ID'></span>
		</td>
		<!-- [20250224]增-承作分區、承作分區 -->
		<td class="tbYellow" width="10%">承作分區</td>
		<td class="tbYellow2" width="15%">
			<span id='AREA_CODE_930318_NM'></span>
			<input type="hidden" name="AREA_CODE_930318" id="AREA_CODE_930318"/>
		</td>
		<td class="tbYellow" width="10%">生活圈名稱</td>
		<td class="tbYellow2" width="40%" colspan="3">
			<input class="textBox2" id="SUBMKT_NAME" name='SUBMKT_NAME' type="text" fieldName='生活圈名稱'/>
			<input type="hidden" name="SUBMKT_ID" id="SUBMKT_ID"/>
			<input type="hidden" name="SUBMKT_VERSION" id="SUBMKT_VERSION"/>
			<input type="hidden" name="AREA_CODE_MATCH_LEVEL" id="AREA_CODE_MATCH_LEVEL"/>
		</td>
	</tr>
	<tr>
		<td align="center" colSpan="8">
			<button id="btn_update" type="button" class="button" strName="update">修正</button>
			<button id="btn_confirm" type="button" class="button" strName="confirm">呈核</button>
			<button id="btn_cancel" type="button" class="button" strName="cancel">取消呈核</button>
			<button id="btn_captainConfirm" type="button" class="button" strName="captainConfirm">組長覆核</button>
			<button id="btn_captainReject" type="button" class="button" strName="captainReject">組長退回</button>
		</td>	
	</tr>
	<tr>
		<td class="tbYellow" width="10%">覆審鑑價進度</td>
		<td class="tbYellow2" width="15%">
			<span id='APPR_PROCESS_NM'></span>
		</td>
		<td class="tbYellow" width="10%">分級</td>
		<td class="tbYellow2" width="15%">
			<span id='REV_LEVEL_NM'></span>
		</td>
		<td class="tbYellow" width="10%">覆審年月</td>
		<td class="tbYellow2" width="15%">
			<span id='REV_YM'></span>
		</td>
		<td class="tbYellow" width="10%">覆審鑑價日期</td>
		<td class="tbYellow2" width="15%">
			<span id='APPR_DATE'></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">覆審鑑價員</td>
		<td class="tbYellow2">
			<span id='APPR_NM'></span>
		</td>
		<td class="tbYellow">前次覆審鑑價員</td>
		<td class="tbYellow2">
			<span id='PRE_APPR_NM'></span>
		</td>
		<td class="tbYellow">前次覆審年月</td>
		<td class="tbYellow2">
			<span id='PRE_REV_YM'></span>
		</td>
		<td class="tbYellow">前次覆審總值</td>
		<td class="tbYellow2">
			<span id='PRE_TOTAL_PRICE'></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">鑑價報告編號</td>
		<td class="tbYellow2">
			<span id='APPR_APPLY_ID'></span>
		</td>
		<td class="tbYellow">使用別</td>
		<td class="tbYellow2">
			<span id='USE_FOR_NM'></span>
		</td>
		<td class="tbYellow">擔保品地址</td>
		<td class="tbYellow2" colspan="3" >
			<span id='ADDR_NO'></span>
		</td>
	</tr>
	<tr>
		<td class="tbYellow">原鑑價人員</td>
		<td class="tbYellow2">
			<span id='ORI_APPR_NM'></span>
		</td>
		<td class="tbYellow">原鑑價組長</td>
		<td class="tbYellow2">
			<span id='ORI_CAPT_NM'></span>
		</td>
		<td class="tbYellow">原鑑估日期</td>
		<td class="tbYellow2">
			<span id='ORI_APPR_DATE'></span>
		</td>
		<td class="tbYellow">原鑑估總值</td>
		<td class="tbYellow2">
			<span id='ORI_TOTAL_PRICE'></span>
		</td>
	</tr>
</table>
<table id="grid2" class="grid"></table>
<table id="grid3" class="grid"></table>
<%-- D區 --%>
<table id="grid4" class="grid"></table>
</div>
</form>
<form id="link_form"></form>
</body>
</html>