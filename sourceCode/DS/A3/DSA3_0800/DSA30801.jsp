<%@ page language="java" contentType="text/html; charset=BIG5"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA30801.jsp
作者：沈志穎
功能：特殊屋況輸入、覆核作業
完成：2021/01/28
[20240930]難字調整
-->
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>

<!-- Import resource，新增請放下面 -->
<fmt:setBundle basename="TextResource" />

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>

<script type='text/javascript' src='${htmlBase}/CM/js/prototype.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/utility.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/TableUI.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/date.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/calendar.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/validation.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/popupWin.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/commView.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/suggest.js'></script> <%-- 搜尋提示用 --%>
<script type='text/javascript' src='${htmlBase}/CM/js/ui/InputUtility.js'></script> <%-- 文字區塊輸入使用 (MEMO) --%>
<script type='text/javascript' src='${htmlBase}/DS/js/DSZ01000.js'></script> <%-- 門牌地址轉全形 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/RPTUtil.js"></script> <%-- 下載用 --%>
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
	Event.observe(window, 'load', new DSA30801().initApp);

	function DSA30801(){

		var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA3_0801/');

		<%-- CoverPage --%>
		var auxiliary = {
			createCoverPage : function() {
				CSRUtil.createCoverPage('_frontCover');
				$('_frontCover').show();
			},
			closeCoverPage: function() {
				$('_frontCover').hide();
			}
		};

		var valid;
		var grid;
		var ACTION = '';
		var OP = '${OP}';

		var buttonAuth = function() {
			var authButtons = {
				  B0001 : 'btn_query'<%--查詢--%>
				, B0003 : 'btn_insert'<%--新增--%>
				, B0004 : 'btn_update'<%--修正--%>
				, B0073 : 'btn_submit'<%--呈核--%>
				, B0085 : 'btn_cancel'<%--取消呈核--%>
				, B0070 : 'btn_approve'<%--覆核--%>
				, B0008 : 'btn_reject'<%--退回--%>
				, B0005 : 'btn_delete'<%--刪除--%>
				, B0099 : 'btn_recover'<%--刪除後回復--%>
				, B0258 : 'btn_posit'<%--定位--%>
				, B0064 : 'btn_upload'<%--上傳--%>
			};
			<dz:grantButtons FUNC_ID="DSA30801" ignored="false"/>
		};

		<%-- 門牌地址: 輸入轉全形 --%>
		var ADDR_NO;

		<%-- 最新的地號資料 --%>
		var latestLandList = []; 
		<%-- 地號空欄位 --%>
		var LAND_EMPTY_ROW = { 
			LAND_LOCATION1 : '',
			LAND_LOCATION2 : '',
			LAND_NO1 : '',
			LAND_NO2 : ''
		};
		
		<%-- for 地號母號/子號 補0 --%>
		var fucFillZero = function( node , dataObj , textDiv, orgData , isOnChange  ) {
			if ( !isOnChange ) { return; }
			if ( !node.value ) { return; }

		    var numPattern = /^\d+$/;
		    if ( !(node.value).match(numPattern) ) {
		    	node.value = '';
		    	node.simulate('change');
		    	return;
		    }

			var dataLength = node.value.length;
			if ( dataLength === 4 ) { return; }

			for (var i = dataLength ; i < 4 ; i++) {
				node.value = '0' + node.value;
			}
			node.simulate('change');
		};

		<%-- 地號資料表格 --%>
		var gridColumn = [
			{ header: "地段", key: "LAND_LOCATION1", 
				input: { type: 'TEXT' , size: 15 , maxlength: 10} 
			},
			{ header: "小段", key: "LAND_LOCATION2", 
				input: { type: 'TEXT' , size: 15 , maxlength: 10} 
			},
			{ header: "地號母號", key: "LAND_NO1", 
				input: {
					  type : 'TEXT'
					, size : 10
					, maxlength : 4
					, action : fucFillZero
				} 
			},
			{ header: "地號子號", key: "LAND_NO2", 
				input: {
					  type : 'TEXT'
					, size : 10
					, maxlength : 4
					, action : fucFillZero
				} 
			},
		];

		<%-- 按鈕 --%>
		var buttons = {

			<%-- 查詢 --%>
			doQuery : function() { 

				<%-- 欄位檢核 --%>
				valid.reset();
				valid.clear();
				valid.define('required' , [{ id : 'Q_SER_NO' , errMsg : '請輸入編號' }]);
				
				if( !valid.validate() ) {
					return;
				}	

				<%-- 啟動查詢 --%>
				ajaxRequest.post('query', { Q_SER_NO : $F('Q_SER_NO') },
					function(resp) { <%-- 查詢完成 --%>
						<%-- 設定畫面資料 --%>
						actions.setFormData(resp);
					},
					function(resp) { <%-- 查無資料、查詢失敗 --%>
						<%-- 清空【建物資料區】、【地號資料區】、【作業資訊區】 --%>

						<%-- 保留原查詢編號 --%>
						var old_Q_SER_NO = $F('Q_SER_NO');
						
						<%-- input tag --%>
						$('form1').reset();
						$$('input[type="hidden"]').forEach(function(ele, index) {
							ele.setValue('');
						});

						<%-- 將原查詢編號回放至查詢條件欄位 --%>
						$('Q_SER_NO').setValue( old_Q_SER_NO );

						<%-- a / span tag --%>
						$$('span').forEach(function(ele, index) {
							if ( ele.hasAttribute('fieldName') ) {
								ele.update('');
							}
						});

						$('SER_NO').update('');
						$('ADDR_NO_TOWN_NAME').update().appendChild(new Element('option', { value: '' }).update('請選擇'));
						$('ADDR_NO_span_INPUT_ZIPCODE').update('');
						InputUtility.lengthLimit.doLengthLimit('MEMO'); <%-- 更新輸入字元數值 --%>
						InputUtility.lengthLimit.doLengthLimit('HOUSE_MEMO');
						InputUtility.lengthLimit.doLengthLimit('SURVEY_CONTENT1');
						InputUtility.lengthLimit.doLengthLimit('SURVEY_CONTENT2');
						latestLandList = []; 
						latestLandList.push(LAND_EMPTY_ROW);
						grid.load(latestLandList);

						<%-- 按鈕控制 --%>
						actions.btnCtrl();
					}
				);
			},

			<%-- 新增 --%>
			doInsert : function() {

				<%-- 欄位檢核 --%>
				valid.reset();
				valid.clear();
				valid.define('required' , [{ id : 'ADDR_NO_CITY_NAME' , errMsg : '請選擇縣市' }]);
				valid.define('required' , [{ id : 'ADDR_NO_TOWN_NAME' , errMsg : '請選擇鄉鎮市區' }]);
				valid.define("required" , [{ id : 'ADDR_NO_INPUT_ADDR' , errMsg : '請輸入門牌地址'}]);
				valid.define('required' , [{ id : 'REASON' , errMsg : '請選擇特殊屋況原因' }]);
				valid.define('required' , [{ id : 'CATEGORY' , errMsg : '請選擇特殊屋況分級' }]);
				valid.define('required' , [{ id : 'IS_CONTROL' , errMsg : '請選擇公告列管' }]);
				valid.define('required' , [{ id : 'SOURCE' , errMsg : '請選擇資料來源' }]);
				actions.setValidationbySOURCE(valid);
				if( !valid.validate() ) {
					return;
				}

				<%-- 啟動新增 --%>
				actions.callTxBean_1('insert');
			},

			<%-- 修正 --%>
			doUpdate : function() {

				<%-- 欄位檢核 --%>
				valid.reset();
				valid.clear();
				valid.define('required' , [{ id : 'ADDR_NO_CITY_NAME' , errMsg : '請選擇縣市' }]);
				valid.define('required' , [{ id : 'ADDR_NO_TOWN_NAME' , errMsg : '請選擇鄉鎮市區' }]);
				valid.define("required" , [{ id : 'ADDR_NO_INPUT_ADDR' , errMsg : '請輸入門牌地址'}]);
				valid.define('required' , [{ id : 'REASON' , errMsg : '請選擇特殊屋況原因' }]);
				valid.define('required' , [{ id : 'CATEGORY' , errMsg : '請選擇特殊屋況分級' }]);
				valid.define('required' , [{ id : 'IS_CONTROL' , errMsg : '請選擇公告列管' }]);
				valid.define('required' , [{ id : 'SOURCE' , errMsg : '請選擇資料來源' }]);
				actions.setValidationbySOURCE(valid);
				if( !valid.validate() ) {
					return;
				}

				<%-- 啟動修正 --%>
				actions.callTxBean_1('update');
			},

			<%-- 呈核 --%>
			doSubmit : function() {

				<%-- 欄位檢核 --%>
				valid.reset();
				valid.clear();
				valid.define('required' , [{ id : 'ADDR_NO_CITY_NAME' , errMsg : '請選擇縣市' }]);
				valid.define('required' , [{ id : 'ADDR_NO_TOWN_NAME' , errMsg : '請選擇鄉鎮市區' }]);
				valid.define("required" , [{ id : 'ADDR_NO_INPUT_ADDR' , errMsg : '請輸入門牌地址'}]);
				valid.define('required' , [{ id : 'REASON' , errMsg : '請選擇特殊屋況原因' }]);
				valid.define('required' , [{ id : 'CATEGORY' , errMsg : '請選擇特殊屋況分級' }]);
				valid.define('required' , [{ id : 'IS_CONTROL' , errMsg : '請選擇公告列管' }]);
				valid.define('required' , [{ id : 'SOURCE' , errMsg : '請選擇資料來源' }]);
				valid.define('required' , [{ id : 'POSIT' , errMsg : '請定位經緯度' }]);
				
				
				if( !valid.validate() ) {
					return;
				}
				
				if(!confirm('請確認定位是否更新')){
					return;
				}

				<%-- 啟動修正 --%>
				actions.callTxBean_1('submit');
			},

			<%-- 取消呈核 --%>
			doCancel : function() {
				<%-- 啟動取消呈核 --%>
				actions.callTxBean_2('cancel');
			},

			<%-- 覆核 --%>
			doApprove : function() {
				<%-- 啟動覆核 --%>
				actions.callTxBean_2('approve');
			},

			<%-- 退回 --%>
			doReject : function() {
				<%-- 啟動退回 --%>
				actions.callTxBean_2('reject');
			},

			<%-- 刪除 --%>
			doDelete : function() {
				if(!confirm('確認刪除此特殊屋況暨公告列管資訊')){
					return;
				}
					
				<%-- 啟動刪除 --%>
				actions.callTxBean_2('delete');
			},
			
			<%-- 刪除後回復 --%>
			doRecover : function() {
				
				<%-- 刪除後回復 --%>
				actions.callTxBean_2('recover');
			},

			<%-- 回上頁 --%>
			doBack : function() {
				if ( window.isPopupWin && window.popupWinClose ) {
					window.popupWinBack('');
				} else if ( window.parent.popupWin ) {
					window.parent.popupWin.back('');
				} else {
					CSRUtil.linkBack();
				}
			}, 

			<%-- 定位 --%>
			doPOSIT : function() {

				<%--【定位】欄位檢核 --%>
				valid.reset();
				valid.clear();
				valid.define("required" , [{ id :"ADDR_NO_INPUT_ADDR" , errMsg : '請輸入門牌地址'}]);
				if( !valid.validate() ) {
					return;
				}

				<%-- 啟動定位 --%>
				ajaxRequest.post('posit', { SER_NO : $('SER_NO').innerHTML, ADDR_NO : ADDR_NO.getINPUT_ADDR() },
					function(resp) { <%-- 定位成功 --%>
						var POSIT = (resp.LONGITUDE || '') + (resp.LATITUDE || '') ? (resp.LONGITUDE || '') + ', ' + (resp.LATITUDE || '') : '';
						$('POSIT').update(POSIT); <%-- 經緯度 --%>
						$('LONGITUDE').setValue(resp.LONGITUDE || ''); <%-- 經度 [隱藏欄位] --%>
						$('LATITUDE').setValue(resp.LATITUDE || ''); <%-- 緯度 [隱藏欄位] --%>
					},
					function(resp) { <%-- 定位失敗 --%>
						$('POSIT').update(''); <%-- 經緯度 --%>
						$('LONGITUDE').setValue(''); <%-- 經度 [隱藏欄位] --%>
						$('LATITUDE').setValue(''); <%-- 緯度 [隱藏欄位] --%>
					}
				);
			},

			<%-- 上傳 --%>
			doUpload : function() {

				<%-- 欄位檢核 --%>
				valid.reset();
				valid.clear();
				valid.define("required" , [{ id :"INPUT_FILE" , errMsg : '請先選擇檔案'}]);
				valid.define("required" , [{ id :"Q_SER_NO" , errMsg : '須先取得編號'}]);
				valid.define("required" , [{ id :"STATUS_NM" , errMsg : '需有狀態'}]);

				if( !valid.validate() ) {
					return;
				}

				<%-- 顯示CoverPage --%>
				auxiliary.createCoverPage();
				<%-- 啟動上傳 --%>
				$('form1').action = '${dispatcher}/DSA3_0801/upload';
				$('form1').submit();
			},

			<%-- 下載 --%>
			doDownload : function() {
				<%-- 啟動下載 --%>
				RPTUtil.downloadFile('${dispatcher}/DSA3_0801/download', { FILE_NAME_SERVER : $F('FILE_NAME_SERVER'), FILE_NAME_DOWNLOAD : $F('FILE_NAME_DOWNLOAD') }, false);
			},

			<%-- 新增-地號資料列 --%>
			addLandRow : function() {
				<%-- 重新取得最新畫面地號資料 --%>
				actions.getLatestLandList();
				<%-- 新增一空列 --%>
				latestLandList.push(LAND_EMPTY_ROW);
				grid.load(latestLandList);
			}, 

			<%-- 刪除-地號資料列 --%>
			delLandRow : function() {

				<%-- 檢核 --%>
				var checkedRec = grid.getCheckedRecord();
				if ( checkedRec.length <= 0 ) {
					alert('【至少須選取一筆地號資料】');
					return;
				}

				<%-- 重新取得最新畫面地號資料 --%>
				actions.getLatestLandList();

				<%-- 刪除畫面地號資料 by sn (並未真的異動DB) --%>
				checkedRec.forEach(function(ele, index) {
					latestLandList.splice(ele.tRows[0].getAttribute('sn')-1-index, 1); <%-- -1: normal offset; -index: offset after splice a element --%>
				});
				grid.load(latestLandList);
			}
		};

		<%-- 動作 --%>				
		var actions = {

			<%-- 初始「按鈕Observe Listener」--%>
			initObserve : function() {

				<%-- 查詢 --%>
				$('btn_query').observe('click', buttons.doQuery);

				<%-- 新增 --%>
				$('btn_insert').observe('click', buttons.doInsert);

				<%-- 修正 --%>
				$('btn_update').observe('click', buttons.doUpdate);

				<%-- 呈核 --%>
				$('btn_submit').observe('click', buttons.doSubmit);

				<%-- 取消呈核 --%>
				$('btn_cancel').observe('click', buttons.doCancel);

				<%-- 覆核 --%>
				$('btn_approve').observe('click', buttons.doApprove);

				<%-- 退回 --%>
				$('btn_reject').observe('click', buttons.doReject);

				<%-- 刪除 --%>
				$('btn_delete').observe('click', buttons.doDelete);

				<%-- 刪除後回復 --%>
				$('btn_recover').observe('click', buttons.doRecover);

				<%-- 回上頁 --%>
				$('btn_back').observe('click', buttons.doBack);

				<%-- 定位 --%>
				$('btn_posit').observe('click', buttons.doPOSIT);

				<%-- 上傳 --%>
				$('btn_upload').observe('click', buttons.doUpload);

				<%-- iframe有匯入時啟動 --%>
				$('importFrame').observe('load', actions.afterUploadEnd);

				<%-- 下載 (腳印) --%>
				$('btn_download').observe('click', buttons.doDownload);

				<%-- 新增-地號資料列 --%>
				$('btn_insert_land').observe('click', buttons.addLandRow);

				<%-- 刪除-地號資料列 --%>
				$('btn_delete_land').observe('click', buttons.delLandRow);

				<%--【建物資料區 - 編號】超連結至審批歷程(DZN00200) --%>
				$('SER_NO').observe('click', actions.linkToDZN00200);
				
				<%--【身故空間輸入框連動】 --%>
				$('DEATH_AREA_OTHER').observe('blur', actions.doDEATH_AREA);
				$('DEATH_TYPE_OTHER').observe('blur', actions.doDEATH_TYPE);
			},

			<%-- 初始「輸入檢核」驗證條件 --%>
			initValidation : function() {
				Validation.addAllThese(
						[
							[
								'validate_DEATH_TYPE'
								, '請輸入身故型態'
								, function( v ) {
									var checked =  $$('input[name=DEATH_TYPE]:checked');
									if (checked.length !=0 && (checked[0].value !='')){
										return true;
									}
									return false;
								}
							],
							[
								'validate_DEATH_AREA'
								, '請輸入身故空間'
								, function( v ) {
									var checked =  $$('input[name=DEATH_AREA]:checked');
									if (checked.length !=0 && (checked[0].value !='' )){
										return true;
									}
									return false;
								}
							]
						]
				);
				valid = new Validation("form1", {useTitles:true, focusOnError:false, immediate:false});
			},

			<%-- 20211109 依照資料來源SOURCE 特殊屋況REASON 調整驗條件--%>
			setValidationbySOURCE : function setValidationbySOURCE( valid ){
				var source = $F('SOURCE');
				if (source == "D"){

					valid.define( "validate-ROCDate" , { id : "SURVEY_DATE1" , errMsg : "訪查時間1錯誤"} );
					valid.define( "required" , { id : "SURVEY_DATE1" , errMsg : "請輸入訪查時間1"} );
					valid.define( "required" , { id : "SURVEY_DEPT1" , errMsg : "請輸入訪查單位1"} );
					valid.define( "required" , { id : "SURVEY_NM1" , errMsg : "請輸入訪查姓名1"} );
					valid.define( "required" , { id : "SURVEY_TEL1" , errMsg : "請輸入訪查電話1"} );
					valid.define( "required" , { id : "SURVEY_CONTENT1" , errMsg : "請輸入訪查內容1"} );

					valid.define( "validate-ROCDate" , { id : "SURVEY_DATE2" , errMsg : "請輸入訪查時間2"} );
					valid.define( "required" , { id : "SURVEY_DATE2" , errMsg : "請輸入訪查時間2"} );
					valid.define( "required" , { id : "SURVEY_DEPT2" , errMsg : "請輸入訪查單位2"} );
					valid.define( "required" , { id : "SURVEY_NM2" , errMsg : "請輸入訪查姓名2"} );
					valid.define( "required" , { id : "SURVEY_TEL2" , errMsg : "請輸入訪查電話2"} );
					valid.define( "required" , { id : "SURVEY_CONTENT2" , errMsg : "請輸入訪查內容2"} );
				}else if(source=='A'||source=='B'||source=='C'||source=='F'||source=='E'||source=='0'){

					valid.define( "validate-ROCDate" , { id : "SOURCE_DATE" , errMsg : "來源資料時間錯誤"} );
					valid.define( "required" , { id : "SOURCE_DEPT" , errMsg : "請輸入來源資料單位"} );
					valid.define( "required" , { id : "SOURCE_DATE" , errMsg : "請輸入來源資料時間"} );
				}else if(source=='G'){
					valid.define( "validate-ROCDate" , { id : "SOURCE_DATE" , errMsg : "來源資料時間錯誤"} );
					valid.define( "required" , { id : "SOURCE_DATE" , errMsg : "請輸入來源資料時間"} );
				}
				var reason = $F('REASON');
				if (reason=='D'){
					valid.define( "validate-ROCDate" , { id : "DEATH_DATE" , errMsg : "身故時間錯誤"} );
					valid.define( "required" , { id : "DEATH_DATE" , errMsg : "請輸入身故時間"} );
					valid.define( "validate_DEATH_AREA" , { id : "DEATH_AREA_OTHER" , errMsg : "請輸入身故空間"} );
					valid.define( "validate_DEATH_TYPE" , { id : "DEATH_TYPE_OTHER" , errMsg : "請輸入身故型態"} );
				}else if(reason == "E" && source=="C"){
					valid.define( "validate-ROCDate" , { id : "BUILD_DATE" , errMsg : "建築完成日錯誤"} );
					valid.define( "validate-ROCDate" , { id : "CL_DATE" , errMsg : "檢測日期錯誤"} );
					valid.define( "required" , { id : "BUILD_DATE" , errMsg : "請輸入建築完成日"} );
					valid.define( "required" , { id : "CL_DATE" , errMsg : "請輸入檢測日期"} );
					valid.define( "required" , { id : "CL_CONC" , errMsg : "請輸入平均氯離子值"} );
				}

			},
			
			<%--「社區名稱建議清單」--%>
			suggest : function() {
				<%-- 社區名稱搜尋，加入suggestion裡面 --%>
				Suggest.add( 
					'COMMUNITY_NAME', 			  
					Suggest.URL,
					'${dispatcher}/DSA3_0801/suggestCaseName',
					{						
						ignoreCase: true,
						startLength: 2,
						option_key: 'COMMUNITY_NAME', <%-- 建議清單左值(查詢資料)，suggestList必為List<Map> --%>
						remark_key: 'COMMUNITY_NO', <%-- 建議清單右值(備註)，suggestList必為List<Map> --%>
						noCookies: true, <%-- 也會決定「歷史查詢資訊Bar」是否顯示 --%>
						callBackFunc: function(node, rec){ $('COMMUNITY_NO').setValue(rec ? rec['COMMUNITY_NO'] : ''); }	
					}
				);
			},

			<%-- 共通ajax  for 【新增】、【修正】、【呈核】--%>
			callTxBean_1 : function(action) {

				ajaxRequest.post(action, {	
						A225DataMap : Object.toJSON(actions.getA225DataMap()), <%--【建物資料區】--%>
						A226DataList : Object.toJSON(actions.getA226DataList()) <%--【地號資料區】--%>
					}, 
					function(resp) { <%-- 作業完成 --%>
						<%-- 設定畫面資料 --%>
						actions.setFormData(resp);

						<%-- 新增時，若有選取附件，須一併將附件作上傳 --%>
						if ( action === 'insert' && $F('INPUT_FILE').length > 0 ) {
							ACTION = 'insert';
							buttons.doUpload();
						}
					}
				);
			},

			<%-- 共通ajax  for 【取消呈核】、【覆核】、【退回】、【刪除】--%>
			callTxBean_2 : function(action) {
				ajaxRequest.post(action, {	
						SER_NO : $('SER_NO').innerHTML, <%-- 編號 --%>
						STATUS : $F('STATUS') <%-- 狀態 [隱藏欄位] --%>
					}, 
					function(resp) { <%-- 作業完成 --%>
						<%-- 設定畫面資料 --%>
						actions.setFormData(resp);
					}
				);
			},

			<%-- 設定畫面資料 --%>
			setFormData : function(resp) {
				<%-- 設定特殊屋況處理紀錄資料 --%>
				actions.setA225MapValues(resp.A225Map);
				<%-- 設定特殊屋況地段紀錄資料 --%>
				latestLandList = resp.A226List;
				grid.load(latestLandList  ? latestLandList  : []);
				<%-- 按鈕控制 --%>
				actions.btnCtrl();
			},

			<%-- 設定特殊屋況處理紀錄資料 --%>
			setA225MapValues : function(A225Map) {
				<%----------------------------------- Row 1 -----------------------------------%>
				$('Q_SER_NO').setValue(A225Map.SER_NO || ''); <%-- 編號 --%>
				$('SER_NO').update(A225Map.SER_NO || ''); <%-- 編號 --%>
				$('STATUS_NM').update(A225Map.STATUS_NM || ''); <%-- 狀態 --%>
				$('INPUT_NM').update(A225Map.INPUT_NM || ''); <%-- 輸入人員 --%>
				$('INPUT_DEPT_NM').update(A225Map.INPUT_DEPT_NM || ''); <%-- 輸入單位 --%>
				$('INPUT_DATE').update(localeDisplay.formatTimestamp( A225Map['INPUT_DATE'] || '' )); <%--  輸入日期--%>

				<%----------------------------------- Row 2 -----------------------------------%>
				$('ADDR_NO_CITY_NAME').setValue(A225Map.CITY || '').simulate('change'); <%-- 縣市 --%>
				$('ADDR_NO_TOWN_NAME').setValue(A225Map.DIST || '').simulate('change'); <%-- 鄉鎮市區 --%>
				ADDR_NO.setINPUT_ADDR(A225Map.ADDR_NO || ''); <%-- 門牌地址 --%>

				<%----------------------------------- Row 3 -----------------------------------%>
				$('COMMUNITY_NAME').value = A225Map.COMMUNITY_NAME || ''; <%-- 社區名稱: 用.value，不用setValue防止觸發suggest --%>
				$('COMMUNITY_NO').value = A225Map.COMMUNITY_NO || ''; <%-- 社區編號: 用.value，不用setValue防止觸發suggest --%>
				$('LICENSE_NO').setValue(A225Map.LICENSE_NO || ''); <%-- 使用執照 --%>
				var POSIT = (A225Map.LONGITUDE || '') + (A225Map.LATITUDE || '') ? (A225Map.LONGITUDE || '') + ', ' + (A225Map.LATITUDE || '') : '';
				$('POSIT').update(POSIT); <%-- 經緯度 --%>

				<%----------------------------------- Row 4 -----------------------------------%>
				$('REASON').setValue(A225Map.REASON || ''); <%-- 特殊屋況原因 --%>
				$('CATEGORY').setValue(A225Map.CATEGORY || ''); <%-- 特殊屋況分級 --%>
				$('IS_CONTROL').setValue(A225Map.IS_CONTROL || ''); <%-- 公告列管 --%>
				$('SOURCE').setValue(A225Map.SOURCE || ''); <%-- 資料來源 --%>

				<%----------------------------------- Row 5 -----------------------------------%>
				actions.setDownloadFoot(A225Map.FILE_NAME); <%-- 設定腳掌圖案及檔案名稱 --%>

				<%----------------------------------- Row 6 -----------------------------------%>
				$('MEMO').setValue(A225Map.MEMO || ''); <%-- 備註 --%>
				InputUtility.lengthLimit.doLengthLimit('MEMO'); <%-- 更新輸入字元數值 --%>

				$('LONGITUDE').setValue(A225Map.LONGITUDE || ''); <%-- 經度 [隱藏欄位] --%>
				$('LATITUDE').setValue(A225Map.LATITUDE || ''); <%-- 緯度 [隱藏欄位] --%>
				$('STATUS').setValue(A225Map.STATUS || ''); <%-- 狀態 [隱藏欄位] --%>

				<%--【作業資訊區】--%>
				$('UPD_NM').update(A225Map.UPD_NM || ''); <%-- 異動人員 --%>
				$('UPD_DEPT_NM').update(A225Map.UPD_DEPT_NM || ''); <%-- 異動單位 --%>
				$('UPD_DATE').update(localeDisplay.formatTimestamp( A225Map['UPD_DATE'] || '' )); <%-- 異動日期 --%>
				$('CFM_NM').update(A225Map.CFM_NM || ''); <%-- 覆核人員 --%>
				$('CFM_DEPT_NM').update(A225Map.CFM_DEPT_NM || ''); <%-- 覆核單位 --%>
				$('CFM_DATE').update(localeDisplay.formatTimestamp( A225Map['CFM_DATE'] || '' )); <%-- 覆核日期 --%>
				
				<%-- 20211109  鑑價作業優化--%>
				$('SOURCE_DEPT').setValue(A225Map.SOURCE_DEPT || '');
				$('SOURCE_DATE').setValue(A225Map.SOURCE_DATE || '');
				$('SOURCE_URL').setValue(A225Map.SOURCE_URL || '');
				$('DEATH_DATE').setValue(A225Map.DEATH_DATE || '');
				$('BUILD_DATE').setValue(A225Map.BUILD_DATE || '');
				
				if ('專有'!=(A225Map.DEATH_AREA|| '')&&'共有'!=(A225Map.DEATH_AREA|| '')){
					$('DEATH_AREA_OTHER').setValue(A225Map.DEATH_AREA|| '');
					actions.doDEATH_AREA();
				} else {
					$('DEATH_AREA_OTHER').setValue(''); //清空自行填寫文字
					actions.doDEATH_AREA();
				}
				actions.setRadioValue($$('input[name=DEATH_AREA]'), A225Map.DEATH_AREA|| '')
				$('CL_DATE').setValue(A225Map.CL_DATE || '');
				if ('自殺'!=(A225Map.DEATH_TYPE|| '')&&'他殺'!=(A225Map.DEATH_TYPE|| '')){
					$('DEATH_TYPE_OTHER').setValue(A225Map.DEATH_TYPE|| '');
					actions.doDEATH_TYPE();
				} else {
					$('DEATH_TYPE_OTHER').setValue(''); //清空自行填寫文字
					actions.doDEATH_TYPE();
				}
				actions.setRadioValue($$('input[name=DEATH_TYPE]'), A225Map.DEATH_TYPE|| '')
				$('CL_CONC').setValue(A225Map.CL_CONC || '');
				$('HOUSE_MEMO').setValue(A225Map.HOUSE_MEMO || '');
				$('SURVEY_DATE1').setValue(A225Map.SURVEY_DATE1 || '');
				$('SURVEY_DEPT1').setValue(A225Map.SURVEY_DEPT1 || '');
				$('SURVEY_NM1').setValue(A225Map.SURVEY_NM1 || '');
				$('SURVEY_TEL1').setValue(A225Map.SURVEY_TEL1 || '');
				$('SURVEY_CONTENT1').setValue(A225Map.SURVEY_CONTENT1 || '');
				$('SURVEY_DATE2').setValue(A225Map.SURVEY_DATE2 || '');
				$('SURVEY_DEPT2').setValue(A225Map.SURVEY_DEPT2 || '');
				$('SURVEY_NM2').setValue(A225Map.SURVEY_NM2 || '');
				$('SURVEY_TEL2').setValue(A225Map.SURVEY_TEL2 || '');
				$('SURVEY_CONTENT2').setValue(A225Map.SURVEY_CONTENT2 || '');
				InputUtility.lengthLimit.doLengthLimit('HOUSE_MEMO');
				InputUtility.lengthLimit.doLengthLimit('SURVEY_CONTENT1');
				InputUtility.lengthLimit.doLengthLimit('SURVEY_CONTENT2');
			},
			
			getRadioValue : function ( radios){
				for( var i=0 ; i<radios.length ; i++ ){
					if( radios[i].checked == true ){
						return radios[i].value;
					}
				}
				return '';
			},
			setRadioValue :function ( radios , value ){
				
				for( var i=0 ; i<radios.length ; i++ ){
					if( radios[i].value == value ){
						radios[i].checked = true;
						break;
					}else{
						radios[i].checked = false;
					}
				}
			},

			<%-- 讀取畫面資料 【A225DataMap】--%>
			getA225DataMap : function() {
				var A225DataMap = {
					SER_NO : $('SER_NO').innerHTML.replace(/ |\n/g, ''), <%-- 編號 --%>					
					CITY : $F('ADDR_NO_CITY_NAME'), <%-- 縣市 --%>
					DIST : $F('ADDR_NO_TOWN_NAME'), <%-- 鄉鎮市區 --%>					
					ADDR_NO : ADDR_NO.getINPUT_ADDR(), <%-- 門牌地址 --%>					
					COMMUNITY_NAME : $F('COMMUNITY_NAME'), <%-- 社區名稱 --%>
					COMMUNITY_NO : $F('COMMUNITY_NO'), <%-- 社區編號 --%>
					LICENSE_NO : $F('LICENSE_NO'), <%-- 使用執照 --%>
					REASON : $F('REASON'), <%-- 特殊屋況原因 --%>
					CATEGORY : $F('CATEGORY'), <%-- 特殊屋況分級 --%>
					IS_CONTROL : $F('IS_CONTROL'), <%-- 公告列管 --%>
					SOURCE : $F('SOURCE'), <%-- 資料來源 --%>
					MEMO : $F('MEMO'), <%-- 備註 --%>
					LONGITUDE : $F('LONGITUDE'), <%-- 經度 [隱藏欄位] --%>
					LATITUDE : $F('LATITUDE'), <%-- 緯度 [隱藏欄位] --%>
					STATUS : $F('STATUS'), <%-- 狀態 [隱藏欄位] --%>
					FILE_NAME_DOWNLOAD : $F('FILE_NAME_DOWNLOAD'), <%-- 上傳檔名 [隱藏欄位] --%>
					<%-- 20211109  鑑價作業優化--%>
					SOURCE_DEPT : $F('SOURCE_DEPT'), 
					SOURCE_DATE : $F('SOURCE_DATE'),
					SOURCE_URL : $F('SOURCE_URL'),
					DEATH_DATE : $F('DEATH_DATE'),
					BUILD_DATE : $F('BUILD_DATE'),
					DEATH_AREA : actions.getRadioValue($$('input[name=DEATH_AREA]')),
					CL_DATE : $F('CL_DATE'),
					DEATH_TYPE : actions.getRadioValue($$('input[name=DEATH_TYPE]')),
					CL_CONC : $F('CL_CONC'),
					HOUSE_MEMO : $F('HOUSE_MEMO'),
					SURVEY_DATE1 : $F('SURVEY_DATE1'), 
					SURVEY_DEPT1 : $F('SURVEY_DEPT1'), 
					SURVEY_NM1 : $F('SURVEY_NM1'), 
					SURVEY_TEL1 : $F('SURVEY_TEL1'), 
					SURVEY_CONTENT1 : $F('SURVEY_CONTENT1'), 
					SURVEY_DATE2 : $F('SURVEY_DATE2'), 
					SURVEY_DEPT2 : $F('SURVEY_DEPT2'), 
					SURVEY_NM2 : $F('SURVEY_NM2'), 
					SURVEY_TEL2 : $F('SURVEY_TEL2'), 
					SURVEY_CONTENT2 : $F('SURVEY_CONTENT2'), 
					
				};
				return A225DataMap;
			},

			<%-- 讀取畫面資料 【A226DataList】--%>
			getA226DataList : function() {
				actions.getLatestLandList();
				return latestLandList;
			},

			<%-- 【建物資料區 - 編號】開啟審批歷程(DZN00200) --%>
			linkToDZN00200 : function() {
				viewBizEvent( $('SER_NO').innerHTML );
			}, 

			<%-- 重新取得最新畫面地號資料 --%>
			getLatestLandList : function() {
				latestLandList = [];
				var records = grid.getAllRecords();
				records.forEach(function(ele, index) {
					var row = { 
						LAND_LOCATION1 : ele['LAND_LOCATION1'],
						LAND_LOCATION2 : ele['LAND_LOCATION2'],
						LAND_NO1 : ele['LAND_NO1'],
						LAND_NO2 : ele['LAND_NO2']
					};
					latestLandList.push(row);
				});
			},

			<%-- 上傳結束的處理 (回傳至form1 -> target: importFrame load -> trigger ) --%>	
			afterUploadEnd : function() {		
				<%-- 隱藏CoverPage --%>
				auxiliary.closeCoverPage();

				<%-- 取得回傳頁面之JSON String --%>
				var ele_filedata = window.importFrame.document.getElementById('filedata');
				if( !ele_filedata ) {
					return;
				}
				var obj = ele_filedata.innerHTML.evalJSON();
				if( !obj ) {
					return;
				}

				<%-- 若上傳失敗顯示上傳結果訊息 --%>
				var ErrMsg = obj.ErrMsg;
				if ( ErrMsg.returnCode != 0 ) { <%-- 失敗皆顯示alert --%>
					alert(ErrMsg.msgDesc.replace('\\n',''));				
				} else { <%-- 成功 --%>
					if ( ACTION != 'insert' ) { <%-- insert不顯示 --%>
						alert(ErrMsg.msgDesc.replace('\\n',''));		
					}
				}

				ACTION = '';

				<%-- 檢核是否上傳成功: returnCode=0 --%>
				if(CSRUtil.isSuccess(obj)) {	
					<%-- 設定腳掌圖案及檔案名稱 --%>
					actions.setDownloadFoot(obj.FILE_NAME_DOWNLOAD);
				}
			},

			<%-- 如果有附件，則顯示腳掌圖案，點腳掌可下載附件 --%>
			setDownloadFoot : function(FILE_NAME_DOWNLOAD) {
				$('FILE_NAME_DOWNLOAD').setValue(FILE_NAME_DOWNLOAD || '');
				if ( $F('FILE_NAME_DOWNLOAD').length > 0 ) {
					$('FILE_NAME_SERVER').setValue($('SER_NO').innerHTML.replace(/ |\n/g, '') + '.' + FILE_NAME_DOWNLOAD.split('.')[1]); <%-- 附件-腳掌 之 檔案名稱 --%>
					$('btn_download').show();
				} else {
					$('FILE_NAME_SERVER').setValue('');
					$('btn_download').hide();
				}
			},

			<%-- 轉換民國格式 --%>
			toROC : function(date, onlyYYYMMdd) {
				return onlyYYYMMdd ? Date.toROC((date || '').split(' ')[0]).replace(/\//g, '') : Date.toROC((date || '').split('.')[0]).replace(/\//g, ''); <%-- global replacement: [/\/] => [/] , [/g] => [global]  let '/' --> '' --%>
			},
			
			doDEATH_AREA : function(){
				$$('input[name=DEATH_AREA]')[2].value = $F('DEATH_AREA_OTHER');
			},
			doDEATH_TYPE : function(){
				$$('input[name=DEATH_TYPE]')[2].value = $F('DEATH_TYPE_OTHER');
			},
			<%-- 按鈕控制 --%>
			btnCtrl : function(){

				var STATUS = $F('STATUS');

				<%-- 除了回上頁，先全部 hide & disabled --%>
				$$('.button:not("#btn_back")').forEach(function(ele, index) {
					ele.hide();
					ele.disable();
				});

				<%-- 查詢: 任何狀態皆Enabled --%>
				$('btn_query').show();
				$('btn_query').enable(); 

				if ( OP === '1' ) { <%-- 輸入作業 --%>

					<%-- 按鈕顯示 --%>
					$('btn_insert').show();
					$('btn_update').show();
					$('btn_submit').show();
					$('btn_cancel').show();
					$('btn_posit').show();
					$('btn_upload').show();
					$('btn_insert_land').show();
					$('btn_delete_land').show();

					<%-- 按鈕狀態 --%>
					if ( STATUS === '0' || STATUS === '2' ) { <%-- 輸入 or 退回 --%>
						$('btn_update').enable();
						$('btn_submit').enable();
						$('btn_posit').enable();
						$('btn_upload').enable();
						$('btn_insert_land').enable();
						$('btn_delete_land').enable();
					} else if ( STATUS === '1' ) { <%-- 呈核 --%>
						$('btn_cancel').enable();
					} else if ( STATUS === ''  ) { <%-- 初始: 新增件 --%>
						$('btn_insert').enable();
						$('btn_insert_land').enable();
						$('btn_delete_land').enable();
					}
				} else if ( OP === '2' ) { <%-- 覆核作業 --%>

					<%-- 按鈕顯示 --%>
					$('btn_approve').show();
					$('btn_reject').show();
					$('btn_delete').show();
					$('btn_recover').show();

					<%-- 按鈕狀態 --%>
					if ( STATUS === '1' ) { <%-- 呈核 --%>
						$('btn_approve').enable();
						$('btn_reject').enable();
						$('btn_delete').enable();
					} else if ( STATUS === '3' ) { <%-- 已覆核 --%>
						$('btn_reject').enable();
						$('btn_delete').enable();
					} else if ( STATUS === '9' ) { <%-- 已刪除 --%>
						$('btn_recover').enable();
					}
				}
				
				//[20210823]申請書210817003961-欄位調整及新增更新作業：僅限RLDS300角色可以修改公告列管、特殊屋況分級
				if("Y"=="${IS_RLDS300}"){
					$('CATEGORY').enable();
					$('IS_CONTROL').enable();
				}else{
					$('CATEGORY').disable();
					$('IS_CONTROL').disable();
				}
			}
		};

		return {                              
			initApp : function() {

				<%-- 統一頁面樣式 --%>
				<cathay:LocaleDisplay sysCode='DS' dateFields="SOURCE_DATE DEATH_DATE BUILD_DATE SURVEY_DATE1 SURVEY_DATE2 CL_DATE " var='localeDisplay' />
				if ( OP === '2' ) {
					PageUI.createPage("DSA30802" , "鑑價作業" , "特殊屋況覆核作業", false);
				} else {
					PageUI.createPage("DSA30801" , "鑑價作業" , "特殊屋況輸入作業", false);
				}
				PageUI.loadin(["form1","grid"], 1);

				<%-- 產表格表頭&定義查詢資料來源 --%>
				grid = new TableUI ({
					table: $("grid"), 
					pageSize: 10, 
					autoCheckBox:{ isSelectAll:true },
					column: gridColumn
				});	

				<%-- 初始「按鈕Observe Listener」--%>
				actions.initObserve();

				<%-- 初始「輸入檢核」驗證條件 --%>
				actions.initValidation();

				<%--「社區名稱建議清單」--%>
				actions.suggest();

				<%-- 輸入備註，連動計算已輸入字元數 --%>
				InputUtility.lengthLimit.add('MEMO', '1500', true, "{enter} / 1500 (字元)");
				InputUtility.lengthLimit.add('HOUSE_MEMO', '500', true, "{enter} / 500 (字元)");
				InputUtility.lengthLimit.add('SURVEY_CONTENT1', '500', true, "{enter} / 500 (字元)");
				InputUtility.lengthLimit.add('SURVEY_CONTENT2', '500', true, "{enter} / 500 (字元)");

				<%-- 門牌地址轉全形 --%>
				ADDR_NO = new DSZ01000("ADDR_NO", "1"); 

				<%-- (先作)按鈕授權 --%>
				//TODO buttonAuth();
				<%-- (再作)按鈕控制 --%>
				actions.btnCtrl();

				<%-- 從審批歷程(DZN00200)點擊回上頁回來，將原本form1的輸入欄位重新填入並查詢 --%>
				var LP_JSON = CSRUtil.isBackLink('form1');
				if ( LP_JSON ) {
					buttons.doQuery();
				}

				<%-- 若為DSA30800超連結連入(有Q_SER_NO)，進行初始查詢 --%>
				if ( '${Q_SER_NO}' ) {
					$('Q_SER_NO').setValue('${Q_SER_NO}');
					buttons.doQuery();
					$('btn_back').enable();
				} else { <%--無: 【地號資料區】預帶一列空欄位 --%>
					latestLandList.push(LAND_EMPTY_ROW);
					grid.load(latestLandList);
				}

				<%-- 顯示底部訊息 --%>
				displayMessage();
			}                 
		}
	}
</script>
</head>

<body>
    <form id="form1" name="form1" method="post" target="importFrame" enctype="multipart/form-data">
		<%------------------------- 【查詢區】 -------------------------%>
        <table id="tableA" class="tbBox2" cellspacing="1" width="100%" border="0">
			<tr>
                <td class="tbYellow"  align="left" width="10%">編號</td>
                <td class="tbYellow2" width="20%">
                    <input id="Q_SER_NO" name="Q_SER_NO" type="text" class="textBox2" title="編號" fieldName="編號" size="15" maxlength="8" />
                </td>

				<td class="tbYellow2" width="70%">
                    <button id="btn_query" name="btn_query" type="button" class="button">查詢</button>
                </td>
            </tr>
			<tr>
				<td align="center" colspan="3">
                    <button id="btn_insert" name="btn_insert" type="button" class="button" disabled >新增</button>
					<button id="btn_update" name="btn_update" type="button" class="button" disabled  >修正</button>
					<button id="btn_submit" name="btn_submit" type="button" class="button" disabled  >呈核</button>
					<button id="btn_cancel" name="btn_cancel" type="button" class="button" disabled  >取消呈核</button>
					<button id="btn_approve" name="btn_approve" type="button" class="button" disabled  >覆核</button>
					<button id="btn_reject" name="btn_reject" type="button" class="button" disabled  >退回</button>
					<button id="btn_delete" name="btn_delete" type="button" class="button" disabled  >刪除</button>
					<button id="btn_recover" name="btn_recover" type="button" class="button" disabled  >刪除後回復</button>
					<button id="btn_back" name="btn_back" type="button" class="button" disabled  >回上頁</button>
                </td>
            </tr>
        </table>


		<%------------------------- 【建物資料區】 -------------------------%>
		<table id="tableD"  class="tbBox2" cellspacing="1" width="100%"  border="0">
			<tr class="tbYellow0" align="middle">
				<td  colspan="8"><strong>建物資料</strong></td>
			</tr>
			<%-- Row 1 --%>
			<tr>
				<td class="tbYellow" width="10%">編號</td>
                <td class="tbYellow2" width="15%">
                    <a id="SER_NO" name="SER_NO" href="javascript:void(0);" fieldName="編號" />
                </td>

				<td class="tbYellow" width="10%">狀態</td>
                <td class="tbYellow2" width="15%">
                    <span id="STATUS_NM" name="STATUS_NM" title="狀態" fieldName="狀態"></span>
                </td>
				<td class="tbYellow" width="10%">建檔人員</td>
                <td class="tbYellow2" width="15%">
                    <span id="INPUT_DEPT_NM" name="INPUT_DEPT_NM"  fieldName="建檔單位"  ></span>&nbsp;
                    <span id="INPUT_NM" name="INPUT_NM"  fieldName="建檔人員" style="font-family:'EUDC'"></span><%--[20240930]難字調整 --%>
				</td>
				<td class="tbYellow" width="10%">建檔日期</td>
                <td class="tbYellow2" width="15%">
                    <span id="INPUT_DATE" name="INPUT_DATE"  fieldName="建檔日期"  ></span>
				</td>
			</tr>

			<%-- Row 2 --%>
			<tr>
                <td class="tbYellow">門牌地址<span style="color:red;">*</span></td>
                <td id="ADDR_NO" name="ADDR_NO" class="tbYellow2" colspan="3" style="font-family:'EUDC'"></td><%--[20240930]難字調整 --%>
                <td class="tbYellow">經緯度</td>
                <td class="tbYellow2" colspan="3">
                    <span id="POSIT" name="POSIT" title="經緯度" fieldName="經緯度" ></span>
					<button id="btn_posit" name="btn_posit" type="button" class="button" disabled >定位</button>
                </td>
            </tr>

			<%-- Row 3 --%>
			<tr>
				<td class="tbYellow">社區編號</td>
				<td class="tbYellow2">
                    <input id="COMMUNITY_NO" name="COMMUNITY_NO" type="text" title="社區編號" fieldName="社區編號" class="textBox2" size="12" maxlength="10" />
                </td>
				<td class="tbYellow">社區名稱</td>
                <td class="tbYellow2">
                    <input id="COMMUNITY_NAME" name="COMMUNITY_NAME" type="text" title="社區名稱" fieldName="社區名稱" class="textBox2" maxlength="40" />
                </td>

				<td class="tbYellow">使用執照</td>
                <td class="tbYellow2" colspan="3">
                    <input id="LICENSE_NO" name="LICENSE_NO" type="text" title="使用執照" fieldName="使用執照" class="textBox2" size="32" maxlength="30" />
                </td>
            </tr>

			<%-- Row 4 --%>
			<tr>
				<td class="tbYellow">特殊屋況原因<span style="color:red;">*</span></td>
                <td class="tbYellow2">
                    <select name="REASON" id="REASON" title="特殊屋況原因" fieldName="特殊屋況原因">
                        <option value="">請選擇</option>
                        <c:forEach var="map" items="${REASON}">
                            <option value="${map.key}">${map.value}</option>
                        </c:forEach>
                    </select>
				</td>

				<td class="tbYellow">特殊屋況分級<span style="color:red;">*</span></td>
                <td class="tbYellow2">
                    <select name="CATEGORY" id="CATEGORY" title="特殊屋況分級" fieldName="特殊屋況分級">
                        <option value="">請選擇</option>
                        <c:forEach var="map" items="${CATEGORY}">
                            <option value="${map.key}" <c:if test="${map.key eq '0'}">selected</c:if>>${map.value}</option>
                        </c:forEach>
                    </select>
				</td>

				<td class="tbYellow">公告列管<span style="color:red;">*</span></td>
				<td class="tbYellow2" width="10%">
                    <select name="IS_CONTROL" id="IS_CONTROL" title="公告列管" fieldName="公告列管">
                        <option value="">請選擇</option>
						<c:forEach var="map" items="${IS_CONTROL}">
                            <option value="${map.key}" <c:if test="${map.key eq '0'}">selected</c:if>>${map.value}</option>
                        </c:forEach>
                    </select>
                </td>

				<td class="tbYellow" width="10%">資料來源<span style="color:red;">*</span></td>
				<td class="tbYellow2" width="10%">
                    <select name="SOURCE" id="SOURCE" title="資料來源" fieldName="資料來源">
                        <option value="">請選擇</option>
						<c:forEach var="map" items="${SOURCE}">
                            <option value="${map.key}" >${map.value}</option>
                        </c:forEach>
                    </select>
                </td>
			</tr>
			<tr>
                <td class="tbYellow">來源單位名稱<span style="color:red;">*</span></td>
                <td class="tbYellow2" colspan="3">                    
					<input id="SOURCE_DEPT" name="SOURCE_DEPT" size='25'maxlength="10"/>
                </td>
                <td class="tbYellow">來源資料時間</td>
				<td class="tbYellow2" colspan="3">
					<input type="text" datatype="ROCDate" id="SOURCE_DATE" name="SOURCE_DATE" class="textBox2" size="10" />
				<span>(資料來源為實價登錄時，請填寫【交易時間】)
				</span>
				</td>
			<tr>
			<tr>
				<td class="tbYellow">來源網址</td>
                <td class="tbYellow2" colspan="7"> 
					<input type="text" id="SOURCE_URL" size="45" maxlength="500">
                </td>
            </tr>
            <tr>
				<td class="tbYellow">非自然身故</td>
				<td class="tbYellow2" colspan="3"> 
					<span>發生時間</span>
					<input type="text" datatype="ROCDate" id="DEATH_DATE" name="DEATH_DATE" class="textBox2" size="10" />
				</td>
                <td class="tbYellow">高氯離子</td>
                <td class="tbYellow2" colspan="3"> 
                	<span>建築完成日期</span>
                	<input type="text" datatype="ROCDate" id="BUILD_DATE" name="BUILD_DATE" class="textBox2" size="10" />
				</td>
            </tr>
            <tr>
            	<td class="tbYellow">身故空間</td>
				<td class="tbYellow2"colspan="3">
					<input type="radio" name='DEATH_AREA'   value='專有'>專有
					<input type="radio" name='DEATH_AREA' value='共有'>共有
					<input type="radio" name='DEATH_AREA'>
					<input type='text' id='DEATH_AREA_OTHER' size="25" maxlength="10"></input>
				</td>
				<td class="tbYellow"></td>
            	<td class="tbYellow2"colspan="3">
					<span>檢測日期  </span>
					<input type="text" datatype="ROCDate" id="CL_DATE">
				</td>
            </tr>
			<tr>
            	<td class="tbYellow">身故型態</td>
				<td class="tbYellow2"colspan="3">
					<input type="radio" name='DEATH_TYPE' value='自殺'>自殺
					<input type="radio" name='DEATH_TYPE' value='他殺'>他殺
					<input type="radio" name='DEATH_TYPE'>
					<input type='text' id='DEATH_TYPE_OTHER' size="25" maxlength="10"></input>
				</td>
				<td class="tbYellow"></td>
            	<td class="tbYellow2"colspan="3">
					<span>平均氯離子值</span>
					<input type="number"  id="CL_CONC" min="0" max="999.999"  step="0.001">
					<span>kg/m3</span>
				</td>
            </tr>
			<tr  >
				<td class="tbYellow">屋況說明</td>
				<td class="tbYellow2" colspan="7">
				<textarea id="HOUSE_MEMO" name="HOUSE_MEMO"  cols="120" title="屋況說明" fieldName="屋況說明" maxlength="500"></textarea>
				</td>

			</tr>
			<tr>
				<td class="tbYellow">訪查時間1</td>
				<td class="tbYellow2">
					<input type="text"id="SURVEY_DATE1" datatype="ROCDate" name="SURVEY_DATE1" class="textBox2" size="10" >
				</td>
				<td class="tbYellow">訪查單位1</td>
            	<td class="tbYellow2">
					<input type="text" id="SURVEY_DEPT1" maxlength="20">
				</td>
				<td class="tbYellow">姓名1</td>
            	<td class="tbYellow2">
					<input type="text"  id="SURVEY_NM1" maxlength="10" alt="ch" /><%--[20240930]難字調整 --%>
				</td>
				<td class="tbYellow">電話1</td>
            	<td class="tbYellow2">
					<input type="text"  id="SURVEY_TEL1"maxlength="20">
				</td>
			</tr>
			<tr>
				<td class="tbYellow">訪查內容1</td>
				<td class="tbYellow2" colspan="7">
					<textarea id="SURVEY_CONTENT1" name="SURVEY_CONTENT1"  cols="120" maxlength="500"></textarea>

				</td>
			</tr>
			<tr>
				<td class="tbYellow">訪查時間2</td>
				<td class="tbYellow2">
					<input type="text" datatype="ROCDate" id="SURVEY_DATE2"  name="SURVEY_DATE2" class="textBox2" >
				</td>
				<td class="tbYellow">訪查單位2</td>
            	<td class="tbYellow2">
					
					<input type="text" id="SURVEY_DEPT2" maxlength="20">
				</td>
				<td class="tbYellow">姓名2</td>
            	<td class="tbYellow2">
					<input type="text"  id="SURVEY_NM2" maxlength="10" alt="ch" /><%--[20240930]難字調整 --%>
				</td>
				<td class="tbYellow">電話2</td>
            	<td class="tbYellow2">
					<input type="text"  id="SURVEY_TEL2" maxlength="20">
				</td>
			</tr>
			<tr rowspan="2" >
				<td class="tbYellow">訪查內容2</td>
				<td class="tbYellow2" colspan="7">
					<textarea id="SURVEY_CONTENT2" name="SURVEY_CONTENT2"  cols="120" ></textarea>

				</td>
			</tr>

			<%-- Row 5 --%>
			<tr>
				<td class="tbYellow">附件<span style="color:red;">*</span></td>
				<td class="tbYellow2" colspan="7">
					<input id="INPUT_FILE" name="INPUT_FILE" type="file" class="file" size="50" title="附件" fieldName="附件" />
					<button id="btn_upload" name="btn_upload" type="button" class="button" disabled >上傳</button>
					<img id="btn_download" name="btn_download" style="cursor: hand; display: none;" src="${imageBase}/DS/star5.gif" border="0">
					<input id="FILE_NAME_SERVER" name="FILE_NAME_SERVER" type="hidden" />
					<input id="FILE_NAME_DOWNLOAD" name="FILE_NAME_DOWNLOAD" type="hidden" />
				</td>
			</tr>

			<%-- Row 6 --%>
			<tr>
				<td class="tbYellow">備註</td>
				<td class="tbYellow2" colspan="7">
					<textarea id="MEMO" name="MEMO" rows="6" cols="120" title="備註" fieldName="備註"></textarea>

					<%-- 隱藏欄位 --%>
					<input id="LONGITUDE" name="LONGITUDE" type="hidden" />
					<input id="LATITUDE" name="LATITUDE" type="hidden" />
					<input id="STATUS" name="STATUS" type="hidden" />
				</td>
			</tr>
        </table>

		<%------------------------- 【地號資料】 -------------------------%>
		<table id="tableE" class="tbBox2" cellspacing="1" width="100%" border="0">
			<tr class="tbYellow0" align="middle">
                <td><strong>地號資料</strong><span style="color:red;">*</span>
					<button id="btn_insert_land" name="btn_insert_land" type="button" class="button" disabled >新增</button>
					<button id="btn_delete_land" name="btn_delete_land" type="button" class="button" disabled >刪除</button>
				</td>
			</tr>
        </table>

		<%------------------------- 【地號資料區】 -------------------------%>
		<table id="grid" class="grid"></table>

		<%------------------------- 【作業資訊區】 -------------------------%>
		<table id="tableF" class="tbBox2" cellspacing="1" width="100%" border="0">
			<tr>
				<td class="tbYellow" width="10%">異動人員</td>
                <td class="tbYellow2" width="15%">
                    <span id="UPD_DEPT_NM" name="UPD_DEPT_NM" title="異動單位" fieldName="異動單位"></span>&nbsp;
                    <span id="UPD_NM" name="UPD_NM" title="異動人員" fieldName="異動人員" style="font-family:'EUDC'"></span><%--[20240930]難字調整 --%>
                </td>
                <td class="tbYellow" width="10%">異動日期</td>
                <td class="tbYellow2" width="15%">
                    <span id="UPD_DATE" name="UPD_DATE" title="異動日期" fieldName="異動日期"></span>
                </td>
				<td class="tbYellow" width="10%">覆核人員</td>
                <td class="tbYellow2" width="15%">
                    <span id="CFM_DEPT_NM" name="CFM_DEPT_NM" title="覆核單位" fieldName="覆核單位"></span> &nbsp;
                    <span id="CFM_NM" name="CFM_NM" title="覆核人員" fieldName="覆核人員" style="font-family:'EUDC'"></span><%--[20240930]難字調整 --%>
                </td>
                <td class="tbYellow" width="10%">覆核日期</td>
                <td class="tbYellow2" width="15%">
                    <span id="CFM_DATE" name="CFM_DATE" title="覆核日期" fieldName="覆核日期"></span>
                </td>
			</tr>
        </table>
    </form>
	<%-- 匯入檔案時，模擬Ajax的效果 --%>
	<iframe id="importFrame" name="importFrame" height="0" size="10" style="display:none"></iframe>
</body>
</html>