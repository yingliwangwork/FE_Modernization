<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />
<!--
程式：DSA31300.jsp
作者：謝雅筑
功能：特殊案件輸入
完成：2012/04/09
[20240930]難字調整
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
<script type='text/JavaScript' src="<%=htmlBase%>/CM/js/date.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/calendar.js"></script>
<script type='text/javascript' src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<%--[20240930]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type='text/javascript'>

<%--全域變數,函數 UI 與 畫面 公用 Start--------------------------------------------------%>
Event.observe(window, 'load', new DSA31300().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA31300(){
	
	var valid;
	var TOWN_Map = {};//儲存已查詢的鄉鎮
	var rtnMapByQuery = {};//查詢出的rtnMap
	
	var buttonAuth = function (){
		var authButtons = {
			B0003:"btn_insert"<%--新增--%> ,
			B0004:"btn_update"<%--修正--%> ,
			B0005:"btn_delete"<%--刪除--%> ,
			B0070:"btn_confirm"<%--覆核--%> ,
			B0071:"btn_cancel"<%--取消覆核--%> ,
			B0104:"btn_recoupCount"<%--已核薪件數扣回--%> ,
			B0105:"btn_updateCnt"<%--修正件數--%> ,
			B0106:"btn_cancelClose"<%--取消結案--%> ,
			B0066:"btn_import"<%--匯入--%>
		};
		<dz:grantButtons FUNC_ID="DSA31300" ignored="false"/>
	};	
					
	var actions = {
		
		//查詢
		doQuery:function(){
			checkInput.clear();
			//檢核條件設定
			checkInput.initDSA31300valid('query');
			if( !valid.validate() ) {
	    		return;
	    	}	

	    	$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			ajaxPost('query',{APPLY_ID:$F('APPLY_ID')},
				function(resp){
					//保留參數管理-更新受理編號
					CSRUtil.keepParamsManager.put({'APPLY_ID': $F('APPLY_ID') });
					commonTools.loadAreaB(resp);
				},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
		},


		//清除
		doClear:function(){
			checkInput.clear();
			var APPLY_ID = $F('APPLY_ID').toUpperCase();
			$('form1').reset();
			$('APPLY_ID').value = APPLY_ID;
			$('TOWN').update().insert(new Element('option', {value: ""}).update("鄉鎮區"));
			$('APPR_ID').update().insert(new Element('option', {value: ""}).update("請選擇"));
			
			$$('#tableB span').each(function(o){
				o.update('');
			});
				
		},
		
		//新增
		doInsert:function(){
			checkInput.clear();

	    	//檢核條件設定
			checkInput.initDSA31300valid('insert');
			checkInput.insertUpdate();
			if( !valid.validate() ) {
	    		return;
	    	}	
	    	
	    	var inputMap = commonTools.getInputData();
	    	inputMap.APPLY_ID = '';
			ajaxPost('insert',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
		},
		
		//修正
		doUpdate:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			checkInput.clear();
			//受理編號檢核
	    	var msg = checkInput.validateApply_ID('update');
	    	if(msg != ''){
	    		alert(msg);
	    		return;
	    	}
	    	
	    	//檢核條件設定
			checkInput.initDSA31300valid('update');
			checkInput.insertUpdate();
			if( !valid.validate() ) {
	    		return;
	    	}
	    	
	    	if(rtnMapByQuery.APPR_TYPE != $F('APPR_TYPE')){
	    		alert('無法修正案件類別,請重新修正!');
	    		return;
	    	}
	    	
	    	var inputMap = commonTools.getInputData();
			ajaxPost('update',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },
	    
		//刪除
		doDelete:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			checkInput.clear();
			
			//受理編號檢核
	    	var msg = checkInput.validateApply_ID('delete');
	    	if(msg != ''){
	    		alert(msg);
	    		return;
	    	}
	    	
	    	if(!confirm('確定要做刪除作業？')){
	    		return;
	    	}
	    	
	    	var inputMap =  commonTools.getInputData();
			ajaxPost('delete',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },
	    
		//覆核
		doConfirm:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			checkInput.clear();
			
			//受理編號檢核
	    	var msg = checkInput.validateApply_ID('confirm');
	    	if(msg != ''){
	    		alert(msg);
	    		return;
	    	}

	    	var inputMap =  commonTools.getInputData();
			ajaxPost('confirm',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },
	    
		//取消覆核
		doCancel:function(){
			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			checkInput.clear();
			
			//受理編號檢核
	    	var msg = checkInput.validateApply_ID('confirm');
	    	if(msg != ''){
	    		alert(msg);
	    		return;
	    	}
	    	
	    	if(!confirm('確定要做取消覆核作業？')){
	    		return;
	    	}

	    	var inputMap =  commonTools.getInputData();
			ajaxPost('cancel',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },
	    
		//已核薪件數扣回
		doRecoupCount:function(){

			checkInput.clear();

	    	//檢核條件設定
			checkInput.initDSA31300valid('recoupCount');
			checkInput.insertUpdate();
			if( !valid.validate() ) {
	    		return;
	    	}
	    	
	    	if(!confirm('確定要做已核薪件數扣回作業？')){
	    		return;
	    	}

	    	var inputMap =  commonTools.getInputData();
			ajaxPost('recoupCount',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },
	    
		//修正件數
		doUpdateCnt:function(){

			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			checkInput.clear();
			
			//受理編號檢核
	    	var msg = checkInput.validateApply_ID('updateCnt');
	    	if(msg != ''){
	    		alert(msg);
	    		return;
	    	}	    	
	    	
	    	//檢核條件設定
			checkInput.initDSA31300valid('updateCnt');
			if( !valid.validate() ) {
	    		return;
	    	}
	    	
	    	if(!confirm('確定要做修正件數作業？')){
	    		return;
	    	}

	    	var inputMap =  commonTools.getInputData();
			ajaxPost('updateCnt',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },
	    
		//取消結案
		doCancelClose:function(){

			$('APPLY_ID').value = $F('APPLY_ID').toUpperCase();
			checkInput.clear();
			
			//受理編號檢核
	    	var msg = checkInput.validateApply_ID('cancelClose');
	    	if(msg != ''){
	    		alert(msg);
	    		return;
	    	}	    	
	    	
	    	//檢核條件設定
			checkInput.initDSA31300valid('cancelClose');
			if( !valid.validate() ) {
	    		return;
	    	}
	    	
	    	var cfmMSG;
	    	if(rtnMapByQuery.PAYMENT != 'Y'){
				cfmMSG = '尚未請款，請確認是否取消結案？';
	    	}else{
	    		cfmMSG = '請確認是否取消結案？';
	    	}
	    	
	    	if(!confirm(cfmMSG)){
	    		return;
	    	}

	    	var inputMap =  commonTools.getInputData();
			ajaxPost('cancelClose',{inputMap:Object.toJSON(inputMap)},
				function(resp){
					commonTools.loadAreaB(resp);
				}
			);
	    },

		//匯出
		doImport:function(){
			var LP_JSON = {
				LINK_FROM:'DSA31300',
				action:'${dispatcher}/DSA3_1301/prompt'
			};
			CSRUtil.linkTo(LP_JSON, 'form1');				
		},

		//取得鄉鎮區
		doGetTOWN_LIST:function(){
			var selectElement = $('TOWN');
			selectElement.update().insert(new Element('option', {value: ""}).update("鄉鎮區"));
			$('GAGE_ZIP').value = '';
			var val = $F('CITY') ;
			if(val == ''){
				return;
			}
			//已查詢過就不用再做查詢
			if(TOWN_Map[val]&&TOWN_Map[val].length > 0){
				var opts = TOWN_Map[val];
				commonTools.createOptions(selectElement,opts,'POSTCODE','TOWN_NAME');			
			}else{
				ajaxPost('getTOWN_LIST',{CITY_NAME : val},
					function(resp){
							var opts = resp.TOWN_LIST;
							TOWN_Map[val] = opts;
							commonTools.createOptions(selectElement,opts,'POSTCODE','TOWN_NAME');	
							
					}
				);
			}		
		},
		
		//取得鑑價人員
		doGetAPPR_ID_LIST:function(){
			var selectElement = $('APPR_ID');
			selectElement.update().insert(new Element('option', {value: ""}).update("請選擇"));
			var val = $F('APPR_GROUP') ;
			if(val == ''){
				return;
			}
			ajaxPost('getAPPR_ID_LIST',{APPR_GROUP : val},
				function(resp){
				var opts = resp.APPR_ID_LIST;
				commonTools.createOptions(selectElement,opts,'ID','NAME');				
					
				}
			);	
		},
		
		// 縣市別, 鄉鎮區連動 縣市別或鄉鎮區異動時,清空GAGE_ADDR
		doGearing: function() {
			
			var GAGE_ADDR = "";
			$$('#CITY option:selected').each(function(ele) {
				if(ele.value){
					GAGE_ADDR = ele.innerHTML;
				}
			});
			
			$$('#TOWN option:selected').each(function(ele) {
				if(ele.value){
					GAGE_ADDR = GAGE_ADDR + ele.innerHTML;
				}
			});
			
			$('GAGE_ADDR').value = GAGE_ADDR;
		}
		
	};
	
	/* 共用ajaxpost function */
	function ajaxPost( actionName, params, successAction ,errorAction){	
		new Ajax.Request( "<%=dispatcher%>/DSA3_1300/" + actionName,
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
	
	var checkInput = {

		//檢核受理編號
		validateApply_ID:function(validAction){
			var v1  = $F('APPLY_ID');
			var v2  = $('APPLY_ID_SPAN').innerHTML;
			var msg = '';

			if(v1 == '' || v2 == ''){
				if(validAction != 'insert'){
					msg='請先輸入受理編號查詢!';
				}
			}else{
				if(validAction != 'insert' ){
					if(v1 != v2){
						msg='欲作業的'+v1+'與原先查詢的'+v2+'不同,請重新查詢!';
					}
				}
			}


			return msg;

		},
		
		//新增,修改 :	B區:特殊案件類別、鑑價組、鑑價人員、借款人或案名、郵遞區號、派件日期必須輸入
		validateRequiredColumn:function(isRequired){
			$w('APPR_TYPE APPR_GROUP APPR_ID CASE_NAME GAGE_ZIP APPLY_DATE').each(
				function(id){
					if(isRequired){
						commonTools.appendVaildName($(id),'required');
					}else{
						commonTools.removeVaildName($(id),'required');
					}
				}
			);
		},
		
		//換算件數
		validateAPPR_COUNT:function(isRequired,isPositive){
			
			if(isRequired){
				commonTools.appendVaildName($('APPR_COUNT'),'required');
				if(isPositive){
					commonTools.appendVaildName($('APPR_COUNT'),'validatePositive');
					commonTools.removeVaildName($('APPR_COUNT'),'validateNegative');
					
				}else{
					commonTools.removeVaildName($('APPR_COUNT'),'validatePositive');
					commonTools.appendVaildName($('APPR_COUNT'),'validateNegative');
				}
				
			}else{
				commonTools.removeVaildName($('APPR_COUNT'),'required');
				commonTools.removeVaildName($('APPR_COUNT'),'validateNegative');
				commonTools.removeVaildName($('APPR_COUNT'),'validatePositive');
			}

		},
		
		initDSA31300valid:function(validAction){
		
			//受理編號
			if(validAction == 'query'){
				commonTools.appendVaildName($('APPLY_ID'),'required');
			}else{
				commonTools.removeVaildName($('APPLY_ID'),'required');
			}
			
			//新增,修改 ,已核薪件數扣回:B區:特殊案件類別、鑑價組、鑑價人員、借款人或案名、郵遞區號、派件日期必須輸入
			if(validAction == 'insert' || validAction == 'update' || validAction == 'recoupCount' ){
				checkInput.validateRequiredColumn(true);
			}else{
				checkInput.validateRequiredColumn(false);
			}
			
			//換算件數
			if(validAction == 'recoupCount'){//已核薪件數扣回
				checkInput.validateAPPR_COUNT(true,false);
			}else if(validAction == 'updateCnt'){//修正件數
				checkInput.validateAPPR_COUNT(true,true);
			}else{
				checkInput.validateAPPR_COUNT(false);
			}
		
		},
		
		//  借款人或案名欄位請檢核長度不可超過60 縣市別、鄉鎮區必須輸入
		insertUpdate: function() {
			valid.define('requiredGAGE_ZIP', {id: 'GAGE_ZIP'});
			valid.define('validateLength', {id: 'CASE_NAME'});
		},
		
		// 檢核清除
		clear: function() {
			// 清空檢核標記
			valid.reset();
			// 清空檢核設定
			valid.clear();
		}
	};

	var commonTools = {			
		
		//取得輸入資料
		getInputData:function(){
			var dataMap = {};
			$$('#tableB input','#tableB select').each(function(o){
				var value = (o.getAttribute('datatype') == 'ROCDate')? toY2K(o.value):o.value;
				dataMap[o.id] = value;

			});
			dataMap.APPLY_ID = $('APPLY_ID_SPAN').innerHTML;
			return dataMap;
		},
		
		loadAreaB:function(resp){
			var rtnMap = resp.rtnMap;
			rtnMapByQuery = rtnMap;
			actions.doClear();//先清空
			if(rtnMap){
				//鑑價人員下選單
				var opts = resp.APPR_ID_LIST;
				if(opts){
					commonTools.createOptions($('APPR_ID'),opts,'ID','NAME');	
				}

				$$('#tableB span').each(function(o){
					var id = o.id.replace('_SPAN','');
					var value = rtnMap[id];
					value = (value==undefined ||value==null  )? '':value;
					if(o.getAttribute('datatype') == 'ROCDate'){
						value = Date.toROC(value);
					}
					o.update(value);
				});
				
				$$('#tableB input','#tableB select').each(function(o){
					var value = rtnMap[o.id]  ;
					value = (value==undefined ||value==null  )? '':value;
					if(o.getAttribute('datatype') == 'ROCDate'){
						value = Date.toInputROC(value,'');
					}
					o.value = value;
				});	
				$('APPLY_ID').value = rtnMap.APPLY_ID;
			}
								
		},
		
		createOptions:function(selectElement, opts, keyName , textName){
			if(opts){
				opts.each(function(opt){
					selectElement.insert(new Element('option', {value: opt[keyName]}).update(opt[textName]));
				});
			}
		},
		
		//增加檢核項目
		appendVaildName:function(ele,vaildName){
			var className = ele.className;
			return ele.className = className.indexOf(vaildName)==-1 ? className + (" "+vaildName):className;
		},
		
		//移除檢核項目
		removeVaildName:function(ele,deleteName){
			var className = ele.className;
			return ele.className = className.replace(deleteName,'').trim();
		}
		
	};

	return{                              
		initApp:function(){
			PageUI.createPageWithAllBodySubElement("DSA31300" , "鑑價作業" , "特殊案件輸入", 1);
			
			valid = new Validation("form1", {useTitles:true,focusOnError:false,immediate:false});
			Validation.addAllThese(
			
			[
				
				['validateGAGE_ZIP', '格式有誤', function(v , node) { 
					if(v !='' && v.length != 3 ){
						return false;
					}else{
						return true;
					}

				}],
				['requiredGAGE_ZIP', '請選擇正確郵遞區號', function(v , node) { 
					if(v ='' ){
						return false;
					}else{
						return true;
					}

				}],
				
				['validatePositive', '需輸入>=0之數字!', function(v , node) { 

					if(v == '' || isNaN(v)){
						return false;
					}else{
						var value =  parseFloat(v);
						if(value >= 0){
							return true;
						}else{
							return false;
						}
					}

				}],
				
				['validateNegative', '需輸入<0之數字!', function(v , node) { 

					if(v == '' || isNaN(v)){
						return false;
					}else{
						var value =  parseFloat(v);
						if(value < 0){
							return true;
						}else{
							return false;
						}
					}

				}],
				['validateLength', '借款人或案名字數過長', function(v , node) { if(!v){return true;} return validation.checkInputLength(v, node.maxLength, node.fullLength, node.halfLength); }]
				
				
			]);

			//查詢
			$('btn_query').observe('click',function(event){actions.doQuery();});
			
			//清除
			$('btn_clear').observe('click',function(event){actions.doClear();});
			
			//新增
			$('btn_insert').observe('click',function(event){actions.doInsert();});	
			
			//修正
			$('btn_update').observe('click',function(event){actions.doUpdate();});	
			
			//刪除
			$('btn_delete').observe('click',function(event){actions.doDelete();});	

			//覆核
			$('btn_confirm').observe('click',function(event){actions.doConfirm();});	
			
			//取消覆核
			$('btn_cancel').observe('click',function(event){actions.doCancel();});
			
			//已核薪件數扣回
			$('btn_recoupCount').observe('click',function(event){actions.doRecoupCount();});	
			
			//修正件數
			$('btn_updateCnt').observe('click',function(event){actions.doUpdateCnt();});	
			
			//取消結案
			$('btn_cancelClose').observe('click',function(event){actions.doCancelClose();});	
			
			//匯入
			$('btn_import').observe('click',function(event){actions.doImport();});	
			
			//「縣市別」下拉選單連動 「鄉鎮區」下拉選單
			$('CITY').observe('change',function(event){
					actions.doGetTOWN_LIST();
					actions.doGearing();
				}
			);
			
			//「鄉鎮區」下拉選單連動 「郵遞區號」
			$('TOWN').observe('change',function(event){
					$('GAGE_ZIP').value  = $F('TOWN');
					actions.doGearing();
				}
			);
			
			//「鑑價組」下拉選單連動 「鑑價人員」下拉選單
			$('APPR_GROUP').observe('change',function(event){
					actions.doGetAPPR_ID_LIST();
				}
			);			
			autoFormatToNumber();
			buttonAuth();
			displayMessage();
			
			if(CSRUtil.isBackLink('form1')){
        		actions.doQuery();
   			}else{
	   			//抓取前端傳過來的值
				var APPLY_ID = '${APPLY_ID}';
				if ( APPLY_ID == "") {
					//保留參數管理-取得受理編號
					APPLY_ID = CSRUtil.keepParamsManager.get('APPLY_ID');
				}
				$('APPLY_ID').value = APPLY_ID;
   			}

		}                 
	}

}
<%--Define UI Class End--------------------------------------------------------%>-->
</script>
</head>
<body>
		<form id="form1" name="form1" method="post">
<!------------------------ A區--------------------->		
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableA">
				<tr>
					<td class="tbYellow"  width="15%">受理編號</td>
					<td class="tbYellow2" width="65%">
						<input id="APPLY_ID" name="APPLY_ID" type="text" fieldName="受理編號" class="textBox2 checkInputLength" size="15" maxlength="11" />
					</td>
					<td class="tbYellow2" width="20%" align="center">
						<input id="btn_query" name="btn_query" type="button" class="button" value="查詢" />
					</td>
				</tr>
				<tr>
					<td colspan="3" align="center">
						<input id="btn_insert" type="button" class="button" value="新增" />
						<input id="btn_update" type="button" class="button" value="修正" />
						<input id="btn_clear" type="button" class="button" value="清除" />
						<input id="btn_delete" type="button" class="button" value="刪除" />
						<input id="btn_confirm" type="button" class="button" value="覆核" />
						<input id="btn_cancel" type="button" class="button" value="取消覆核" />
						<input id="btn_recoupCount" type="button" class="button" value="已核薪件數扣回" />
						<input id="btn_updateCnt" type="button" class="button" value="修正件數" />
						<input id="btn_cancelClose" type="button" class="button" value="取消結案" />
						<input id="btn_import" type="button" class="button" value="匯入" />
					</td>
				</tr>
			</table>
<!------------------------ B區--------------------->	
			<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id="tableB">
	 			<tr>
	 				<input id="BOSS_ID" name="BOSS_ID" type="hidden"/>
	 				<td class="tbYellow"  width="15%">受理編號</td>
	 				<td class="tbYellow2"  width="35%"><span id="APPLY_ID_SPAN"></span></td>
                    <td class="tbYellow" width="15%">特殊案件類別</td>
                    <td class="tbYellow2" width="35%">
						<select name="APPR_TYPE" id="APPR_TYPE"  fieldName="特殊案件類別">
							<option value="">請選擇</option>
							<c:forEach var="map" items="${APPR_TYPE_LIST}">
								<c:if test="${map.key != '0'}">
									<option value="${map.key}">${map.value}</option>
								</c:if>
							</c:forEach>
						</select>
					</td>
				</tr>
				<tr>
					<td class="tbYellow">鑑價組</td>
                    <td class="tbYellow2">
						<select name="APPR_GROUP" id="APPR_GROUP"  fieldName="鑑價組">
							<option value="">請選擇</option>
							<c:forEach var="map" items="${APPR_GROUP_LIST}">
								<option value="${map.key}">${map.value}</option>
							</c:forEach>
						</select>
					</td>
					<td class="tbYellow">鑑價人員</td>
                    <td class="tbYellow2">
						<select name="APPR_ID" id="APPR_ID" fieldName="鑑價人員" alt="ch"><%--[20240930]難字調整 --%>
							<option value="">請選擇</option>
						</select>
					</td>
				</tr>
				<tr>
					<td class="tbYellow">借款人或案名</td>
					<td class="tbYellow2">
						<input id="CASE_NAME" name="CASE_NAME" type="text" class="textBox2" size="30"  maxlength="60" fieldName="借款人或案名" alt="ch"/><%--[20240930]難字調整 --%>
					</td>
	 				<td class="tbYellow">受理進度</td>
	 				<td class="tbYellow2"><span id="APPLY_PROCESS_NM_SPAN"></span></td>
				</tr>
				<tr>
					<td class="tbYellow">縣市</td>
                    <td class="tbYellow2">
                    	<input id="GAGE_ZIP" name="GAGE_ZIP" type="text" class="textBox2" size="3" maxLength="3" fieldName="3碼郵遞區號" disabled/>
						<select name="CITY" id="CITY" fieldName="縣市別">
							<option value="">縣市別</option>
							<c:forEach var="map" items="${CITY_LIST}"> 
								<option value="${map.CITY_NAME}" >${map.CITY_NAME}</option>
							</c:forEach>
						</select>
						<select name="TOWN" id="TOWN" fieldName="鄉鎮區">
							<option value="">鄉鎮區</option>
						</select>
						<input id="GAGE_ADDR" name="GAGE_ADDR" type="text" class="textBox2" size="30" fieldName="地址" alt="ch" /><%--[20240930]難字調整 --%>
					</td>
	 				<td class="tbYellow">結案日期</td>
	 				<td class="tbYellow2"><span id="CLOSE_DATE_SPAN" datatype="ROCDate" ></span></td>
				</tr>
				<tr>
					<td class="tbYellow">換算件數</td>
					<td class="tbYellow2">
						<input id="APPR_COUNT" name="APPR_COUNT" type="text" datatype="number" pattern="#,###.#" class="textBox2 validate-number" size="5" maxLength="6" fieldName="換算件數" />
					</td>
					<td class="tbYellow">派件日期</td>
					<td class="tbYellow2">
						<input type="text" datatype="ROCDate" fieldName="派件日期" class="textBox2 validate-ROCDate" size="8" maxlength="7" name=APPLY_DATE id="APPLY_DATE" />
						<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" width="20" height="18" onclick="getCalendarFor($('APPLY_DATE'))">
					</td>
				</tr>
				<tr>
					<td class="tbYellow">覆核人員</td>
	 				<td class="tbYellow2"><span id="BOSS_NM_SPAN" style="font-family:'EUDC'"></span><%--[20240930]難字調整 --%></td>
					<td class="tbYellow">覆核日期</td>
	 				<td class="tbYellow2"><span id="REPORT_DATE_SPAN" datatype='ROCDate'></span></td>
	 			</tr>
				<tr>
					<td class="tbYellow">作業人員</td>
	 				<td class="tbYellow2"><span id="INPUT_NM_SPAN" style="font-family:'EUDC'"></span><%--[20240930]難字調整 --%></td>
					<td class="tbYellow">作業日期</td>
	 				<td class="tbYellow2"><span id="INPUT_DATE_SPAN" datatype='ROCDate'></span></td>
	 			</tr>
				<tr>
					<td class="tbYellow">第一次覆核日</td>
	 				<td class="tbYellow2" colspan="3"><span id="FIRST_BOSS_DATE" datatype='ROCDate'></span></td>
	 			</tr>
				<tr>
				<td colspan="4" class="tbYellow2">
				＊修改未核薪鑑價案件換算件數，可由<font color='red'>修正件數</font>修改。<BR>
				<font color='red'>(15號之前可修改第一次覆核日為當月及上月資料，15號過後，僅可修改當月資料)</font><BR>
				＊已核薪資料欲扣回，可由<font color='red'>已核薪件數扣回</font>，換算件數請輸入負值，並在借款人或案名輸入備註事項。
				</td>
				</tr>
			</table>
	 </form>
</body>
<!-- InstanceEnd -->
</html>