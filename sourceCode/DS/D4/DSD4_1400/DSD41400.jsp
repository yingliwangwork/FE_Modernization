<!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01 Transitional//EN'>

<!--
程式：DSD41400.jsp
功能：清償文件交付控管作業
作者：官振凱
完成：2019-04

[20210802]修改件

[20220223]問題單20220223150034
1.新增文件不全連結 
2.簽收條狀態查詢調整 
3.服中主管未覆核，簽收條不可歸檔 
4.將查詢框內的歸檔與下面簽收條歸檔合併成一個功能，查詢框內的歸檔就不呈現於畫面。
郭曉慧

[20240328]
難字調整
高強禾
 -->
<html>
<head>
<meta http-equiv='Content-Type' content='text/html; charset=big5'>
<meta http-equiv="X-UA-Compatible" content="IE=5.5"> 

<%@ page language='java' contentType='text/html; charset=BIG5'%>
<%@ include file='/html/CM/header.jsp'%>
<%@ include file='/html/CM/msgDisplayer.jsp'%><!--顯示接收到的錯誤訊息-->
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<title></title>
<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
 
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type='text/javascript' src="${htmlBase}/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>         <%-- 報表列印 --%>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/suggest.js'></script>
<script language="JavaScript" src="${htmlBase}/CM/js/ui/popupWin.js"></script> 
<%-- [20240328] 難字調整 --%>
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
Event.observe(window, 'load', new DSD41400().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);
function DSD41400(){
	var grid;
	var valid1, valid2;
    var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSD4_1400/');//建立 ajax request 物件
	
	function initValidation(){
		//新增/修改用檢核		
		Validation.addAllThese([
			[ 'required-STR-APPLY-DATE', '貸款帳號與客戶ID無輸入時，塗銷申請起日為必輸'
				, function(v, element) {
					var date_str = $F('STR_APPLY_DATE'),
						loan_id = $F('LOAN_ID'),
						borrow_id = $F('BORROW_ID');
					if(Validation.get('IsEmpty').test(loan_id) && Validation.get('IsEmpty').test(borrow_id)){
						if(Validation.get('IsEmpty').test(date_str)){
							return false;
						}
					}
					return true;
				}
			],
			[ 'required-END-APPLY-DATE', '貸款帳號與客戶ID無輸入時，塗銷申請迄日為必輸'
				, function(v, element) {
					var date_end = $F('END_APPLY_DATE'),
						loan_id = $F('LOAN_ID'),
						borrow_id = $F('BORROW_ID');
					if(Validation.get('IsEmpty').test(loan_id) && Validation.get('IsEmpty').test(borrow_id)){
						if(Validation.get('IsEmpty').test(date_end)){
							return false;
						}
					}
					return true;
				}
			],
			[ 'oneMonthInterval', '塗銷申請日區間必在1個月內，請縮小查詢範圍'
				, function(v, element) {
					var date_str = $F('STR_APPLY_DATE'),
						date_end = $F('END_APPLY_DATE');

					if(!Validation.get('IsEmpty').test(date_str) && !Validation.get('IsEmpty').test(date_end)){	//確認有輸入
						if(isROCdate(date_str)){
							return !(diffDayROC(date_str, date_end) > 30);
						}else{
							return !(diffDayY2K(date_str, date_end) > 30);
						}
					}
					 
					return true;
				}
			],
			['checkInputLength', '輸入值超出長度限制', function( v , element  ) {
				return validation.checkInputLength( v , element.maxlength );
			}],
			['checkInputLengthEQ10', '輸入值超出長度限制', function( v , element  ) {
				if(v){
					return v.length == 10;
				}
				return true;
			}],
			['validate-digits-word', '需為英數字', function(v) {
				return Validation.get('IsEmpty').test(v) || /^(\d|\w)+$/.test(v);
			}],
			[ 'checkLOGINDIV', '服務中心僅允許查詢自單位案件'
				, function(v, element) {
					var LOGIN_DIV = $F('LOGIN_DIV'),
						RECEIVE_DEPTNO = $F('RECEIVE_DEPTNO');
					//單位是服中，且領取單位非自單位，跳出警示訊息
					if(!Validation.get('IsEmpty').test(LOGIN_DIV)){//確認有輸入
						if(LOGIN_DIV != RECEIVE_DEPTNO){
							return false;
						}
					}
					return true;
				}
			]
		]);
		valid1 = new Validation('form', {focusOnError:true, immediate:false , mode: 'validator'});
		valid2 = new Validation('grid', {focusOnError:true, immediate:false , mode: 'validator'});

		valid1.define('required-STR-APPLY-DATE', {id: 'STR_APPLY_DATE', errMsg: '貸款帳號與客戶ID無輸入時，塗銷申請起日為必輸'});
		valid1.define('required-END-APPLY-DATE', {id: 'END_APPLY_DATE', errMsg: '貸款帳號與客戶ID無輸入時，塗銷申請迄日為必輸'});
		valid1.define('oneMonthInterval', {id: 'END_APPLY_DATE', errMsg: '塗銷申請起迄日不可超過30天'} );
		valid1.define('validate-digits-word', {id: 'LOAN_ID', errMsg: '貸款帳號需為英數字'});
		valid1.define('validate-digits-word', {id: 'BORROW_ID', errMsg: '客戶ID需為英數字'});
		valid1.define('checkInputLengthEQ10', {id: 'LOAN_ID', errMsg: '貸款帳號長度需為10碼'});
		valid1.define('checkInputLength', {id: 'BORROW_ID', errMsg: '客戶ID長度最多10碼'});
		valid1.define('checkLOGINDIV', {id: 'RECEIVE_DEPT', errMsg: '服務中心僅允許查詢自單位案件'});
	}
	
	//按鈕授權
	function buttonAuth(){
		var authButtons = {
			B0003: 'btn_insert',//新增
			B0004: 'btn_modify',//修改
			B0031: 'btn_updateSIGN',//文件送出
			B0008: 'btn_linkDSD4_1606',//退回補全
			B0089: 'btn_confirm',//簽收條歸檔
			B0090: 'btn_deconfirm',//取消歸檔
			B0245: 'btn_sendprint',//郵寄列印
			B0246: 'btn_conprint',//通訊列印
			B0082: 'btn_signPrint'//簽收條名細列印
		};		
		<dz:grantButtons FUNC_ID="DSD41400"/>
	};
	
	var actions = {
		initialize: function(){
			if('${LOGIN_DIV}'){
				$('RECEIVE_DEPT').setValue('${LOGIN_DIVNM}');
				$('RECEIVE_DEPTNO_DIS').update('${LOGIN_DIV}');
				$('RECEIVE_DEPTNO').setValue('${LOGIN_DIV}');
				$('LOGIN_DIV').setValue('${LOGIN_DIV}');
			}
		},
		getParams: function(target){
			if(!target){
				return {};
			}
			var $target = $(target);

			var params = {};
			<%--[20220223]排除SIGN_STATUS--%>
			<%--[20220919]驗測問題，直接改用CASE_STATUS查詢--%>
			$target.select('input[type!=button],  textarea, span, select').each(function(elem){
				var $elem = $(elem),
					name = $elem.getAttribute('name'),
					id = $elem.getAttribute('id'),
					field = name||id,
					tagNM = $elem.tagName;
				if(!field){
					return;
				}

				var val;
				switch(tagNM){
					case 'INPUT':
						val = $elem.getValue();
						break;
					case 'SELECT':
						val = $elem.value;
						break;
					case 'TEXTAREA':
						val = $elem.getValue();
						break;
					case 'SPAN':
						val = $elem.innerHTML;
						break;
				};
				if(!val){
					return;
				}

				params[field] = val;
			});

			if(params['PROC_EMP']){
				params['INPUT1_ID'] = params['PROC_EMP'];
			}
			return params;
		},
		<%--[20210802]新增程式碼: 新增方法doLink  --%>
		<%-- popupWin指定頁面 --%>
		doPopup: function(linkTo, rec){
			popupWin.popup({
    			src : '${dispatcher}/'+linkTo+'/prompt',
    			scolling : 'yes',
    			parameters : {
    				REFER_ID : rec.REFER_ID,
    				APPLY_DATE : rec.APPLY_DATE,
    				LINK_FROM : 'DSD41400',
    				CASE_STATUS : rec.CASE_STATUS
    			}
			});
		},
		<%--[20210802]新增程式碼: 新增方法updateSignOrCaseStatus  --%>
		<%-- 文件送出或歸檔 --%>
		updateSignOrCaseStatus: function(action, chName){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}
			
			var allDataList = grid.getAllRecords();
			if(!allDataList || allDataList.length == 0){
				alert('請先查詢再執行'+ chName +'作業');
				return;
			}
			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length == 0){
				alert('請先選取再執行'+ chName +'作業');
				return;
			}
			
			var reqList = [];
			dataList.forEach(function(dataMap){
				var reqMap = {
					'REFER_ID' : dataMap.REFER_ID,
					'APPLY_DATE' : dataMap.APPLY_DATE,
					'CASE_STATUS' : dataMap.CASE_STATUS
				}
				reqList.push(reqMap);
			});
			ajaxRequest.post(action, {'reqList':Object.toJSON(reqList), 'params':Object.toJSON(actions.getParams($('form')))}, 
				function(resp){
					grid.load(resp.rtnList||[]);
				}
			);
		},
		englishToUpperCase : function() {
	    	this.value = this.value.toUpperCase();
	    }
	};

	var buttons = {		
		doQuery: function(event){
			valid1.reset();
			if(!valid1.validate()){
				return;			
			}

			grid.show();
			var formData = Object.toJSON(actions.getParams($('form')));
			ajaxRequest.post('query', {params: formData},
				function(resp){
					grid.load(resp.rtnList||[]);
				},function(resp){
					grid.load([]);
				});
		},
		doInsert: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請先選取再執行新增作業');
				return;
			}

			ajaxRequest.post('insert', {params: Object.toJSON(actions.getParams($('form'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				},function(resp){
				});
		},
		<%-- 修改 --%>
		doModify: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請先選取再執行修改作業');
				return;
			}

			ajaxRequest.post('modify', {params: Object.toJSON(actions.getParams($('form'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				},function(resp){
				});
		},
		<%-- 通訊列印 --%>
		doConPrint: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord(['LOAN_ID', 'APPLY_DATE', 'BORROW_NAME']);
			if(!dataList || dataList.length === 0){
				alert('請先選取再執行郵寄列印作業');
				return;
			}

			var number = prompt('請輸入條碼標籤位置(由左至右分別為1,2,3,4)，請輸入數字1~4', 1);
			if (!number) {
				return;
			}
			
			RPTUtil.downloadFile('${dispatcher}/DSD4_1400/conprint' , {dataList: Object.toJSON(dataList), number: number}, true);
		},
		<%-- 郵寄列印 --%>
		doSendPrint: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord(['LOAN_ID', 'APPLY_DATE']);
			if(!dataList || dataList.length === 0){
				alert('請先選取再執行郵寄列印作業');
				return;
			}

			RPTUtil.downloadFile('${dispatcher}/DSD4_1400/sendprint' , {dataList: Object.toJSON(dataList)}, true);
		},
		<%-- 簽收條名細列印 --%>
		doSignPrint: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord(['LOAN_ID', 'APPLY_DATE']);
			if(!dataList || dataList.length === 0){
				alert('請先選取再執行簽收回條名細列印作業');
				return;
			}

			RPTUtil.executeCreateXlsFile('${dispatcher}/DSD4_1400/signprint', {dataList: Object.toJSON(dataList)});
		},
		<%-- 簽收條歸檔 --%>
		doConfirm: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請先查詢再執行簽收條歸檔作業');
				return;
			}

			ajaxRequest.post('confirm', {params: Object.toJSON(actions.getParams($('form'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				},function(resp){
				});
		},
		<%-- 取消歸檔 --%>
		doDeConfirm: function(event){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}

			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length === 0){
				alert('請先查詢再執行取消歸檔作業');
				return;
			}

			ajaxRequest.post('deconfirm', {params: Object.toJSON(actions.getParams($('form'))), dataList: Object.toJSON(dataList)},
				function(resp){
					grid.load(resp.rtnList||[]);
				},function(resp){
				});
		},
		<%-- 文件送出 --%> <%-- [20210802]新增程式碼 --%>
		doUpdateSIGN: function(){ 
			actions.updateSignOrCaseStatus('updateSIGN', '文件送出');
		},
		<%-- 歸檔 --%> <%-- [20210802]新增程式碼 --%>
		<%-- [20220224]移除歸檔相關程式 --%>
		<%-- 退回補全 --%> <%-- [20210802]新增程式碼 --%>
		doLinkDSD4_1606: function(){
			valid2.reset();
			if(!valid2.validate()){
				return;			
			}
			var dataList = grid.getCheckedRecord();
			if(!dataList || dataList.length == 0){
				alert('請先選取再執行退回補全');
				return;
			}else if(dataList.length > 1){
				alert('只能勾選一筆資料作業');
				return;
			}
			
			var dataMap = dataList[0];
			popupWin.popup({
    			src : '${dispatcher}/DSD4_1606/prompt',
    			width : '100%',
    			height : '100%',
    			scolling : 'yes',
    			parameters : {
    				REFER_ID : dataMap.REFER_ID,
    				APPLY_DATE : dataMap.APPLY_DATE,
    				READONLY : 'N',
    				LINK_FROM : 'DSD41400',
    				CASE_STATUS : dataMap.CASE_STATUS
    			},
    			onBack : function(){	
    				buttons.doQuery();
    			}
			});
		}
	};

	return {
			
		initApp : function(){
			<cathay:LocaleDisplay sysCode="DS" var="localeDisplay" dateFields="STR_APPLY_DATE END_APPLY_DATE"/>
			PageUI.createPageWithAllBodySubElement('DSD41400', '清償作業', '清償文件交付控管作業');
			
			Suggest.add(
				"RECEIVE_DEPT",	// (必填)建議輸入欄位的ID
				Suggest.URL,	// (必填)建議輸入的設定型態(動態查詢型態)
				"/DSWeb/servlet/HttpDispatcher/DSD4_1400/queryDEPT",	// (必填)至後端查詢資料的網址。
				{
					"option_key":"DIV_NAME",
					"remark_key":"DIV_NO",
					"dispMax":10,
					"prefix":false,
					"ignoreCase":true,
					"startLength":2,
					"noCookies":true,
					"callBackFunc" : function(node, rec){
						var val = rec ? rec['DIV_NO']: '';
						$('RECEIVE_DEPTNO').setValue(val);
						$('RECEIVE_DEPTNO_DIS').update(val);
					}
				}	// (選填)其他設定值們
			);
			grid = new TableUI ( {
					table:$("grid"), pageSize: 5, allSortable:true ,
					split: ["APPLY_DATE"],
					autoCheckBox:{ type: "checkbox", text:'選取', isSelectAll: true},
					<%-- [20240328] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					//2019-08-01 林孟平 需要綁定pageChange事件，否則第二頁之後不會執行下方function
					pageChange: function(nowPage, totalPage, mainDiv, table_id){
						
						<%-- [20240328] 難字調整 --%>
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						
						//suggest:單位名稱->單位代號
						$(mainDiv).select('.DS-suggest01').each(function(elem){
							if(elem.getAttribute('id') && elem.getAttribute('id').indexOf('suggest_') == 0){
								//第一頁會執行pageChange兩次，所以增加return判斷，已經add過不要再加
								return;
							}
							var $elem = $(elem);
							Suggest.add(
								elem,	// (必填)建議輸入欄位的ID
								Suggest.URL,	// (必填)建議輸入的設定型態(動態查詢型態)
								"/DSWeb/servlet/HttpDispatcher/DSD4_1400/queryDEPT",	// (必填)至後端查詢資料的網址。
								{
									"option_key":"DIV_NAME",
									"remark_key":"DIV_NO",
									"dispMax":10,
									"prefix":false,
									"ignoreCase":true,
									"startLength":2,
									"noCookies":true,
									"params":{"eletag":"DIV_NAME"},
									"callBackFunc" : function(node, rec){
										var data = grid.getDataObj(node);
										data['RECEIVE_DEPT'] = (rec ? rec['DIV_NAME'] : '');
										data['RECEIVE_DEPTNO'] = (rec ? rec['DIV_NO'] : '');
										data['ZIP_CODE'] = (rec ? rec['ZIP_CODE'] : '');
										data['DIV_ADDRESS'] = (rec ? rec['DIV_ADDRESS'] : '');
	
										var parent = $elem.up('div'),
											elem_DEPTNO = $(parent.select('input.deptno')[0]);
										elem_DEPTNO.value = (rec ? rec['DIV_NO'] : '');
										
										//連動寄送地址
										grid.setValueToTD( node , 'ZIP_ADDR' , (rec ? rec['ZIP_ADDR'] : ''));
									}
								}
							);
                        });
						
						//suggest:單位代號->單位名稱
						$(mainDiv).select('.DS-suggest02').each(function(elem){
							if(elem.getAttribute('id') && elem.getAttribute('id').indexOf('suggest_') == 0){
								//第一頁會執行pageChange兩次，所以增加return判斷，已經add過不要再加
								return;
							}
							var $elem = $(elem);
							Suggest.add(
								elem,	// (必填)建議輸入欄位的ID
								Suggest.URL,	// (必填)建議輸入的設定型態(動態查詢型態)
								"/DSWeb/servlet/HttpDispatcher/DSD4_1400/queryDEPT",	// (必填)至後端查詢資料的網址。
								{
									"option_key":"DIV_NO",
									"remark_key":"DIV_NAME",
									"dispMax":10,
									"prefix":false,
									"ignoreCase":true,
									"startLength":2,
									"noCookies":true,
									"params":{"eletag":"DIV_NO"},
									"callBackFunc" : function(node, rec){
										var data = grid.getDataObj(node);
										data['RECEIVE_DEPT'] = (rec ? rec['DIV_NAME'] : '');
										data['RECEIVE_DEPTNO'] = (rec ? rec['DIV_NO'] : '');
										data['ZIP_CODE'] = (rec ? rec['ZIP_CODE'] : '');
										data['DIV_ADDRESS'] = (rec ? rec['DIV_ADDRESS'] : '');
	
										var parent = $elem.up('div'),
											elem_DEPTNAME = $(parent.select('input.deptname')[0]);
										elem_DEPTNAME.value = (rec ? rec['DIV_NAME'] : '');
										
										//連動寄送地址
										grid.setValueToTD( node , 'ZIP_ADDR' , (rec ? rec['ZIP_ADDR'] : ''));
									}
								}
							);
                        });
                    },
					column:[
						{header: "原貸帳號",key: "LOAN_ID"},
						<%-- [20240328] 難字調整：客戶姓名 --%>
						{header: "客戶姓名",key: "BORROW_NAME",attrs:{ style:"font-family:'EUDC'" }},
						{header: "交付方式",key: "SEND_KIND", 
							render: function(rec, val, sn){
								var select = new Element('select',{id:"SEND_KIND_"+sn});
								select.add(new Option('請選擇', ''));
								<c:forEach var="entry" items="${SEND_KIND_LIST}">
									select.add(new Option('${entry.value}', '${entry.key}'));
								</c:forEach>
								if(val){
									select.setValue(val);
									rec['SEND_KIND'] = val;
								}else{
									select.setValue('');
									rec['SEND_KIND'] = '';
								}
								select.observe('change', function(){
									rec['SEND_KIND'] = this.value;
								});

								return select;
							}},
						{header: "案件狀態",key: "CASE_STATUS_NM" <%-- [20210802]修改程式碼: 'SIGN_STATUS_NM'改成'CASE_STATUS'以及新增render --%>  
							,render:function(rec, val, sn){ 
								if(!val){
									return '';
								}
								<%--[20220223]CASE_STATUS=05改超連結--%>
								if('05' == rec.CASE_STATUS){
									var link = new Element('a', { href : 'javascript:void(0);' });
									link.update((val||''));
									link.observe('click', function(){
										actions.doPopup('DSD4_1602', rec);
									});
									return link;
								}
								return rec.CASE_STATUS_NM||'';//[20220919]模組已轉中文，不需要在jsp轉一次
							}
						},
						<%-- [20240328] 難字調整：單位地址 --%>
						{header: "單位地址",key: "ZIP_ADDR",attrs:{ style:"font-family:'EUDC'" }},
						{header: "補全項目",key: "CASE_STATUS" <%-- [20210802]新增程式碼: 新增欄位 --%>
							,render:function(rec, val, sn){ 
								if(!val && val!='0'){
									return '';
								}
								var link = new Element('a', { href : 'javascript:void(0);' });
								link.update('補全項目');								
								link.observe('click', function(){
									actions.doPopup('DSD4_1606', rec);
								});
								return link;
							}	
						}, 
						{header: "服中確認",key: "RECEIVE_ID"}, <%-- [20210802]新增程式碼: 新增欄位 --%>
						{header: "服中簽收",key: "SIGN_ID"}, <%-- [20210802]新增程式碼: 新增欄位 --%>
						{header: "塗銷申請日",key: "APPLY_DATE", sortRule: 'date'},
						<%-- [20240328] 難字調整：資管科經辦 --%>
						{header: "資管科經辦",key: "SEND_NAME",attrs:{ style:"font-family:'EUDC'" }},<%-- [20210802]修改程式碼: 客戶ID 改成 資管科經辦 --%><%--[申請書:230511008861]清償文件簽收電訪卡控:改成顯示姓名--%>
						{header: "交付單位",key: "RECEIVE_DEPT",
							render: function(rec, val, sn){
								<%-- [20240220]問題單-20240130-0051：因單位異動(單位名稱不變，僅變更單位代號)，SUGGEST機制導致無法選取正確單位代號，改為也可用單位代號查詢帶出其他單位資訊--%>
								var div = new Element('div'),
									input_divname = new Element('input', {'type': 'input', 'class': 'input deptname DS-suggest01' ,'size':'15' ,'maxlength':'25'}).setValue(val||''),
									input_divno = new Element('input', {'type': 'input', 'class': 'input deptno DS-suggest02' ,'size':'10' ,'maxlength':'7'}).setValue(rec['RECEIVE_DEPTNO']||'');

								div.insert(input_divno).insert(input_divname);

								return div;
							}},
						{header: "收執編號",key: "RECEIPT_NO",
							input: {
								type:'text',
								attrs: {'maxlength': 20},
								className: ['checkInputLength', 'validate-digits-word', 'input']
							}},
						{header: "備註",key: "COMMENT",
							input: {
								type:'textarea',
								attrs: {'maxlength': 100, cols: 50},
								className: ['checkInputLength', 'input']
							}},
						{header: "文件上傳影像檔",key: "CASE_STATUS" <%-- [20210802]新增程式碼: 新增欄位 --%>
							,render:function(rec, val, sn){ 
								if(!val || isNaN(val) || (parseInt(val)<25)){
									return '';
								}
								var link = new Element('a', { href : 'javascript:void(0);' });
								link.update('影像查詢');								
								link.observe('click', function(){
									actions.doPopup('DSD4_1605', rec);
								});
								return link;
							}	
						}, 
						{header: "服中確認日期",key: "RECEIVE_DATE", sortRule: 'date'}, <%-- [20210802]新增程式碼: 新增欄位 --%>
						{header: "服中簽收日期",key: "SIGN_DATE", sortRule: 'date'}, <%-- [20210802]新增程式碼: 新增欄位 --%>
					]
				});
			
			$('btn_query').observe('click', buttons.doQuery);
			$('btn_insert').observe('click', buttons.doInsert);
			$('btn_modify').observe('click', buttons.doModify);
			$('btn_conprint').observe('click', buttons.doConPrint);
			$('btn_sendprint').observe('click', buttons.doSendPrint);
			$('btn_signPrint').observe('click', buttons.doSignPrint);
			$('btn_confirm').observe('click', buttons.doConfirm);
			$('btn_deconfirm').observe('click', buttons.doDeConfirm);
			$('btn_updateSIGN').observe('click', buttons.doUpdateSIGN); <%-- 文件送出 --%> <%-- [20210802]新增程式碼 --%>
			<%-- 歸檔 --%> <%-- [20210802]新增程式碼 --%> 
			<%--[20220224]移除歸檔相關程式--%>
			$('btn_linkDSD4_1606').observe('click', buttons.doLinkDSD4_1606); <%-- 退回補全 --%> <%-- [20210802]新增程式碼 --%>
		    <%-- [20220301]問題單[20220225170023] 1.新增貸款帳號、客戶ID查詢，英文輸入主動轉大寫 --%>
			$('LOAN_ID').observe('change', actions.englishToUpperCase);
			$('BORROW_ID').observe('change', actions.englishToUpperCase);
			
			grid.hide();

			initValidation();
			actions.initialize();
			buttonAuth();
			//初始頁面alert訊息用	
			displayMessage();
		}
	}
}
</script>
</head>
<body>
<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
	<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2" id='table1'>
		<tr>
			<td class="tbYellow" width="15%">塗銷申請日</td>		
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" name="STR_APPLY_DATE" id="STR_APPLY_DATE" value="${CURRENT_DATE}"/>
				~
				<input type="text" class="input" name="END_APPLY_DATE" id="END_APPLY_DATE" value="${CURRENT_DATE}"/>
			</td>		
			<td class="tbYellow" width="15%">交付方式</td>		
			<td class="tbYellow2" width="30%">
				<select class="input" name="SEND_KIND" id="SEND_KIND">
					<option value>全部</option>
					<c:forEach var="entry" items="${SEND_KIND_LIST}">
						<option value="${entry.key}">${entry.value}</option>
					</c:forEach>
				</select>
			</td>		
			<td class="tbYellow2" width="10%" align= "center" rowspan="4">
				<button type="button" class="button" id="btn_query">查詢</button>
				<button type="button" class="button" id="btn_updateSIGN">文件送出</button>
				<button type="button" class="button" id="btn_linkDSD4_1606">退回補全</button>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">承辦科別</td>
			<td class="tbYellow2" width="30%">
				<select class="input" name="CRED_DEPT" id="CRED_DEPT">
					<option value>全部</option>
					<c:forEach var="entry" items="${CRED_DEPT_LIST}">
						<option value="${entry.key}">${entry.value}</option>
					</c:forEach>
				</select>
			</td>		
			<td class="tbYellow" width="15%">領取單位</td>
			<td class="tbYellow2" width="30%">
				<input id="RECEIVE_DEPT" type="text" maxlength="25"/>
				<span id="RECEIVE_DEPTNO_DIS"></span>
				<input type="hidden" name="RECEIVE_DEPTNO" id="RECEIVE_DEPTNO"/>
				<input type="hidden" name="LOGIN_DIV" id="LOGIN_DIV"/><!-- 登入者為服務中心，僅允許查詢自單位代號 -->
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">資管科經辦</td>
			<td class="tbYellow2" width="30%">
				<%-- [20240328] 難字調整：資管科經辦 --%>
				<select class="input" name="PROC_EMP" id="PROC_EMP" alt="ch">
					<option value>全部</option>
					<c:forEach var="entry" items="${PROC_EMP_LIST}">
						<option value="${entry.key}" <c:if test="${userId eq entry.key}">selected</c:if>>${entry.value}</option>
					</c:forEach>
				</select>
			</td>		
			<td class="tbYellow" width="15%">貸款帳號</td>
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" maxlength="10" name="LOAN_ID" id="LOAN_ID"/>
			</td>
		</tr>
		<tr>
			<td class="tbYellow" width="15%">案件狀態</td>
			<td class="tbYellow2" width="30%">
				<select class="input" name="CASE_STATUS" id="CASE_STATUS">
					<option value="">全部</option>
					<c:forEach var="entry" items="${CASE_STATUS_LIST}">
						<option value="${entry.key}">${entry.value}</option>
					</c:forEach>
				</select>
			</td>		
			<td class="tbYellow" width="15%">客戶ID</td>
			<td class="tbYellow2" width="30%">
				<input type="text" class="input" maxlength="10" name="BORROW_ID" id="BORROW_ID"/>
			</td>
		</tr>
	</table>
</form>
<div style="text-align: center;" class="tbYellow2">
	<button type="button" class="button" id="btn_insert">新增</button>
	<button type="button" class="button" id="btn_modify">修改</button>
	<button type="button" class="button" id="btn_conprint">通訊列印</button>
	<button type="button" class="button" id="btn_sendprint">郵寄列印</button>
	<button type="button" class="button" id="btn_signPrint">簽收條明細列印</button>
	<button type="button" class="button" id="btn_confirm">簽收條歸檔</button>
	<button type="button" class="button" id="btn_deconfirm">取消歸檔</button>
</div>
<table id="grid"></table>
</body>
</html>