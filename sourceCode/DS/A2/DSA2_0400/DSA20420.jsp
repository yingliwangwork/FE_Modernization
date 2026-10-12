<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA20420.jsp
功能：聯徵查詢紀錄查核作業
作者：劉芷均
完成：2018/3/23

[20210708] 修改件:聯徵公務機關資料查調作業
[20210907] 問題單:20210906155210 葉威揚
1.設定初始值 2.【承辦科別】移除disable屬性。
[20211007] 問題單:20211006221117 
1.新增備註欄位及新增備註按鈕
 -->
 
<html>
<head>

<meta http-equiv="Content-Type" content="text/html; charset=BIG5">
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<link href='${cssBase}/cm.css' rel='stylesheet' type='text/css'>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/prototype.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ajax/CSRUtil.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/PageUI.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/TableUI.js"></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/calendar.js"></script>
<script type="text/javaScript" src="${htmlBase}/CM/js/ui/LocaleDisplay.js "></script>
<script type="text/javascript" src="${htmlBase}/CM/js/ui/popupWin.js"></script>
<script type="text/JavaScript" src="${htmlBase}/CM/js/RPTUtil.js"></script>
<%--[20240729]難字css  --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
    src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
         url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
   font-weight: normal;
   font-style: normal
}
</style>
<script type="text/javaScript">
	// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行 initApp()
	Event.observe(window, 'load', new DSA20420().initApp);
		
    function DSA20420() {   		
    	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0420/');
    	var grid;
		var valid;

		function buttonAuth(){
			var authButtons = {
				B0001:'BTN_query'   <%-- 查詢--%>
				,B0004:'BTN_save'	<%-- 儲存--%>
				,B0006:'BTN_check'	<%-- 查核確認--%>
				,B0019:'BTN_boss'	<%-- 主管覆核--%>
				,B0020:'BTN_reject'	<%-- 退回--%>
				,B0021:'BTN_export'	<%-- 匯出報表--%>
				,B0003:'BTN_updateNote'	<%-- 新增備註--%> <%-- [20211007]新增程式碼 --%>
			};
			<dz:grantButtons FUNC_ID="DSA20420"/>
		};

		var actions = {
			getRecords : function(){
				var records={
					CHARGEID : $F('CHARGEID')	<%-- 承辦科別--%>
					,QPROC : $F('QPROC')		<%-- 查詢進度--%>
					,STAQDATE : $F('STAQDATE')	<%-- 查詢起日--%>
					,ENDQDATE : $F('ENDQDATE')	<%-- 查詢迄日--%>
					,CHECK_ITEM : $F('CHECK_ITEM') <%-- [20210708]  查核項目  --%>
					,REQUESTID : $F('USERNAME') <%-- [20210708]  承辦人員  --%>
					,NOTE : $F('NOTE') <%-- [2022.02.21]  備註  --%>
				};
				return records;
			},

			initValidation:function(){
				valid = new Validation($('form1'), {useTitles:false, mode: "validate" });

				valid.define('required' , [{ id : "STAQDATE" , errMsg:"查詢起日不可為空"}] );
				valid.define('required' , [{ id : "ENDQDATE" , errMsg:"查詢迄日不可為空"}] );

				valid.define('validate-Date-Interval', 
					[{id:"STAQDATE", errMsg:""}, {id:"ENDQDATE", errMsg:"查詢起日(起)需小於等於查詢起日(迄)"}]);
					valid.define('requiredEND_DT' , [{ id : "STAQDATE" }] );
					valid.define('requiredEND_DT' , [{ id : "ENDQDATE" }] );

				Validation.addAllThese([
					['requiredEND_DT', '查詢起迄日區間不可超過一個月!', function(){
						var time_different = diffDayY2K($F('STAQDATE'), $F('ENDQDATE'));
						if( time_different &&  time_different >31){
							return false;
						}
						return true;
					}]
				]);
			},

			get_Save_Check : function (save){
				var saveList = [];
				for ( var i=0; i<save.length; i++ ){
					var save_map = save[i];
					var map = {};
					map['IS_VALID'] = save_map['IS_VALID'] || '';
					map['DATA_TYPE'] = save_map['DATA_TYPE'] || '';
					map['APPLY_ID'] = save_map['APPLY_ID'] || '';
					map['QDATE'] = save_map['QDATE'] || '';
					map['TXID'] = save_map['TXID'] || '';
					map['MSGID'] = save_map['MSGID'] || '';
					map['QUERY_ID'] = save_map['QUERY_ID'] || '';
					map['AUDIT_TIME'] = save_map['AUDIT_TIME'] || '';
					map['BOSS_TIME'] = save_map['BOSS_TIME'] || '';
					map['REQUESTID'] = save_map['REQUESTID'] || '';
					saveList.push(map);
				}
				return saveList;
			},

			get_BossList : function (save){
				var bossList = [];
				for ( var i=0; i<save.length; i++ ){
					var save_map = save[i];
					var map = {};
					map['APPLY_ID'] = save_map['APPLY_ID'] || '';
					map['QDATE'] = save_map['QDATE'] || '';
					map['TXID'] = save_map['TXID'] || '';
					map['MSGID'] = save_map['MSGID'] || '';
					map['AUDIT_TIME'] = save_map['AUDIT_TIME'] || '';
					map['BOSS_TIME'] = save_map['BOSS_TIME'] || '';
					bossList.push(map);
				}
				return bossList;
			},

			set_grid : function(resp){
				var rtnList = resp.rtnList || [] ;
				grid.load(rtnList);
			},
			
			getUserNameList : function(){ <%-- [20210708] 修改件:聯徵公務機關資料查調作業 --%>
				
				var CHARGEID = $F('CHARGEID');
				var userNameList = $("USERNAME");
				userNameList.update();
				
				userNameList.options.add(new Option( "全部" , "")); 
				if('ALL' !== CHARGEID){
					//發送ajax
					ajaxRequest.post( 'getUserName' , {reqMap : Object.toJSON({'CHARGEID' : CHARGEID})},
						function(resp){	
							var list = resp.rtnList;
							if(list){
								for(var i = 0; i < list.length; i++){ 
									userNameList.options.add(new Option(list[i]['USRNAME'], list[i]['REQUESTID'])); 
								}
							}
							<%-- [20210907]【查核項目】為[公務機關資料查詢確認]時，【承辦科別】USERNAME預帶登入者。--%>
							if( $F('CHECK_ITEM') === 'Z52' && CHARGEID === "${INPUT_CRED_DEPT}" ){
								userNameList.setValue("${EMP_ID}");
							}
						}
					);
				}
			},
			
			buildGrid : function(inputKind){ <%-- [20210708] 修改件:聯徵公務機關資料查調作業 --%>
				var kind = event.target.value || inputKind;
				<%-- [20210907] 【查核項目】為[每日查核]時，預帶登入者科別 ,無值則預帶[全部]--%>
				<c:if test="${not empty INPUT_CRED_DEPT}">
					$('CHARGEID').setValue("${INPUT_CRED_DEPT}");
					actions.getUserNameList();
				</c:if>
				if('Z50' == kind){
					$('BTN_save').disabled = false;
					$('BTN_updateNote').disabled = true;
					grid = new TableUI({
						table : $('grid')
						,whenDataNull : ''
						,overDiv : true
						,pageSize: 10
						,allSortable: true
						,autoCheckBox : { isSelectAll : true  }
						<%-- [20240729] 難字調整 --%>
						,afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						}
						,pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						}
						,column : [
							{header : "查詢日期", key:"QDATE"} 
							,{header : "時間", key:"QTIME"}
							,{header : "使用人員代號", key:"REQUESTID"}
							,{header : "使用人員姓名", key:"USRNAME", attrs:{style:"font-family:'EUDC'"} } <%-- [20240729]難字調整 --%>
							,{header : "方式", key:"QUERY_WAY_NM"}
							,{header : "項目", key:"TXID"}
							,{header : "查詢對象ID", key:"QUERY_ID"}
							,{header : "查詢對象", key:"QUERY_NAME", attrs:{style:"font-family:'EUDC'"} } <%-- [20240729]難字調整 --%>
							,{header : "查詢資料原因", key:"REASON_NM"}
							,{header : "是否符合規範", key:"IS_VALID"
								,render: function(rec, val, sn){
									var span = new Element('sapn', {'id':'IS_VALID_MRK', 'validnm':'IS_VALID_MRK'});
									var span_1 = new Element('sapn').update("是");
									var span_2 = new Element('sapn').update("否");
									var IS_VALID_MRK = 'IS_VALID_MRK' + sn;
									var IS_VALID_MRK_Y = new Element('input', {'type':'radio', 'value':'Y', 'name':IS_VALID_MRK});
									var IS_VALID_MRK_N = new Element('input', {'type':'radio', 'value':'N', 'name':IS_VALID_MRK});
									span.insert(span_1);
									span.insert(IS_VALID_MRK_Y);
									span.insert(span_2);
									span.insert(IS_VALID_MRK_N);

									IS_VALID_MRK_Y.onclick = function(){
										rec['IS_VALID'] = 'Y';
									};
									IS_VALID_MRK_N.onclick = function(){
										rec['IS_VALID'] = 'N';
									};

									if (val){
										if ('Y'== val){
											IS_VALID_MRK_Y.checked = true;
										} else {
											IS_VALID_MRK_N.checked = true
										}
									}
									return span;
								}
							}
							,{header : "資料類型", key:"DATA_TYPE"
								,render: function(rec, val, sn){
									var span = new Element('sapn', {'id':'DATA_TYPE_MRK', 'validnm':'DATA_TYPE_MRK'});
									var span_1 = new Element('sapn').update("影像檔");
									var span_2 = new Element('sapn').update("紙本文件");
									var DATA_TYPE_MRK_Y = 'DATA_TYPE_MRK_Y'+sn;
									var DATA_TYPE_MRK_N = 'DATA_TYPE_MRK_N'+sn;
									var DATA_TYPE_MRK = 'DATA_TYPE_MRK'+sn;
									var DATA_TYPE_MRK_1 = new Element('input', {'id':DATA_TYPE_MRK_Y, 'type':'radio', 'name':DATA_TYPE_MRK});
									var DATA_TYPE_MRK_2 = new Element('input', {'id':DATA_TYPE_MRK_N, 'type':'radio', 'name':DATA_TYPE_MRK});
									span.insert(DATA_TYPE_MRK_1);
									span.insert(span_1);
									span.insert(new Element('br'));
									span.insert(DATA_TYPE_MRK_2);
									span.insert(span_2);

									var id = 'APPLY_ID' + sn;
									var BTN_link = 'BTN_link' + sn;

									if (val){
										if ('1'== val){
											DATA_TYPE_MRK_1.checked = true;
										} else {
											DATA_TYPE_MRK_2.checked = true;
										}
									}

									DATA_TYPE_MRK_1.onclick = function(){
										$(id).enable();
										$(BTN_link).enable();
										rec['DATA_TYPE'] = '1';
									};
									DATA_TYPE_MRK_2.onclick = function(){
										$(id).disable();
										$(id).setValue('');
										$(BTN_link).disable();
										rec['DATA_TYPE'] = '2';
										rec['APPLY_ID'] = ''; //空白字串
									};
									return span;
								}
							}
							,{header : "受理編號輸入", key:"APPLY_ID"
								,render: function(rec, val, sn){
									var id = 'APPLY_ID'+sn;
									var APPLY_ID = new Element('input', {'id':id, 'type':'text', 'class':'tbYellow2', 'maxlength':'11'});

									if (val){
										APPLY_ID.value = val;
									}

									if ('2' == rec.DATA_TYPE){
										APPLY_ID.disable();
										APPLY_ID.value = '';
									}else if(rec.AUDIT_NAME){
										APPLY_ID.disable();
									}

									APPLY_ID.observe('change',function(){
										rec['APPLY_ID'] = $F(id);
									})
									return APPLY_ID;
								}
							}
							,{header : "影像連結", key:""
								,render: function(rec, val, sn){
									var BTN_link = 'BTN_link' + sn;
									var btn = new Element('button', {'id':BTN_link,'type': 'button', 'class': 'button'}).update("影像連結");
									btn.observe('click', function(){
										popupWin.windowOpen(
											'${dispatcher}/DSA0_0200/prompt'
											,{'parameters' : {'APPLY_ID' : rec.APPLY_ID, 'fieldName' : 'ITEM6'}} 
										);
									});
									if ('2' == rec.DATA_TYPE){
										btn.disable();
									}
									return btn;
								}
							}
							,{header : "查核人員", key:"AUDIT_NAME", attrs:{style:"font-family:'EUDC'"} } <%-- [20240729]難字調整 --%>
							,{header : "主管覆核", key:"BOSS_NAME", attrs:{style:"font-family:'EUDC'"} } <%-- [20240729]難字調整 --%>
							,{header : "結案日期", key:"BOSS_DATE", sortRule: 'date'}
						]
					});
				}
				else if('Z52' == kind){
					$('BTN_save').disabled = true;
					grid = new TableUI({
						table : $('grid')
						,whenDataNull : ''
						,overDiv : true
						,pageSize: 10
						,allSortable: true
						,autoCheckBox : { isSelectAll : true  }
						<%-- [20240729] 難字調整 --%>
						,afterLoad: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						}
						,pageChange: function() {
							if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						}
						,column : [
							{header : "查詢日期", key:"QDATE"},
							{header : "時間", key:"QTIME"},
							{header : "使用人員代號", key:"REQUESTID"},
							{header : "查詢人員", key:"USRNAME", attrs:{style:"font-family:'EUDC'"} }, <%-- [20240729]難字調整 --%>
							{header : "方式", key:"QUERY_WAY_NM"},
							{header : "項目", key:"TXID"},
							{header : "查詢對象ID", key:"QUERY_ID"},
							{header : "查詢對象", key:"QUERY_NAME", attrs:{style:"font-family:'EUDC'"} }, <%-- [20240729]難字調整 --%>
							{header : "查核人員", key:"AUDIT_NAME", attrs:{style:"font-family:'EUDC'"} }, <%-- [20240729]難字調整 --%>
							{header : "主管覆核", key:"BOSS_NAME", attrs:{style:"font-family:'EUDC'"} }, <%-- [20240729]難字調整 --%>
							{header : "結案日期", key:"BOSS_DATE", sortRule: 'date'},
							<%--[2022.02.21]優化by詩婷:在上方增加一行備註欄，可多選多筆案件並一次新增備註。--%>
							{header : "備註", key:"NOTE"
								//input:{ type:'textArea', rows:3, cols:35, maxlength:100, disableRule:("${nodeDisabled}"=="true") }
							}
						]
					});
				}
			}
		};

		var buttons ={
			<%-- 查詢--%>
			doQuery : function(){
				if(!valid.validate()){
					return ;
				}

				ajaxRequest.post(
					'query'
					,{reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
					,function(resp){
						grid.load([]);
					}
				);
			},

			<%-- 儲存--%>
			doSave : function(){
				var save = grid.getCheckedRecord();
				if (save.length <= 0){
					alert('請選取一筆資料');
					return;
				}
				var saveList = actions.get_Save_Check(save);

				ajaxRequest.post(
					'save'
					,{saveList : Object.toJSON(saveList), reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
				);
			},

			<%-- 查核確認--%>
			doCheck : function(){
				var check = grid.getCheckedRecord();
				if (check.length <= 0){
					alert('請選取一筆資料');
					return;
				}
				var auditList = actions.get_Save_Check(check);

				ajaxRequest.post(
					'check'
					,{auditList : Object.toJSON(auditList), reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
				);
			},

			<%-- 主管覆核--%>
			doBoss : function(){
				var boss = grid.getCheckedRecord();
				if (boss.length <= 0){
					alert('請選取一筆資料');
					return;
				}
				var bossList = actions.get_BossList(boss);

				ajaxRequest.post(
					'boss'
					,{bossList : Object.toJSON(bossList), reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
				);							
			},

			<%-- 退回--%>
			doReject : function(){
				var reject = grid.getCheckedRecord();
				if (reject.length <= 0){
					alert('請選取一筆資料');
					return;
				}
				var rejectList = actions.get_BossList(reject);

				ajaxRequest.post(
					'reject'
					,{rejectList : Object.toJSON(rejectList), reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
				);							
			},

			<%-- 匯出匯出csv檔--%>
			doExport : function(){

			    if(!valid.validate()){
					return ;
				}

				ajaxRequest.post(
					'query'
					,{reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
				);

				var reqMap = actions.getRecords();
				var titleName = '聯徵查詢查核紀錄';
				reqMap.gridJSON = grid.getXlsSettingJSON(titleName);

				RPTUtil.executeCreateXlsFile('${dispatcher}/DSA2_0420/export',
					{ reqMap : Object.toJSON(reqMap), titleName : titleName}
				);
			},
			<%-- 新增備註 --%>
			doUpdateNote : function(){ <%-- [20211007]新增程式碼: 新增doUpdateNote方法 --%>
				var reqList = grid.getCheckedRecord();
				if (reqList.length == 0){
					alert('至少選取一筆資料');
					return;
				}
				<%--[2022.02.21]優化by詩婷:在上方增加一行備註欄，可多選多筆案件並一次新增備註。--%>
				<%--
				var errMsg = "";
				reqList.forEach(function (data, i){
					var note = data.NOTE
					var tempMsg = ("勾選的第 "+(i+1)+" 筆資料 [備註] 欄位")
					if(!note){
						errMsg += (tempMsg+"不可為空\n");
					}else if(note.length > 100){
						errMsg += (tempMsg+"長度不可大於100\n");
					}
				});
				--%>
				var note = $F('NOTE');
				if(!note){
					alert("[備註]不可為空");
				}else if(note.length > 100){
					alert("[備註]長度不可大於100");
				}
				ajaxRequest.post(
					'updateNote'
					,{reqList : Object.toJSON(reqList), reqMap : Object.toJSON(actions.getRecords())}
					,function(resp){
						actions.set_grid(resp);
					}
				);
			}
			
		}
				
        return {
            initApp: function(){
            	<cathay:LocaleDisplay dateFields="STAQDATE ENDQDATE" sysCode= 'DS' var='localeDisplay' />            	
                PageUI.createPageWithAllBodySubElement(
					'DSA20420',
					'核貸作業',
					'聯徵查核作業'
				);
				
 				actions.initValidation();
 
				$('BTN_query').observe('click', buttons.doQuery);
				$('BTN_save').observe('click', buttons.doSave);
				$('BTN_check').observe('click', buttons.doCheck);
				$('BTN_boss').observe('click', buttons.doBoss);
				$('BTN_reject').observe('click', buttons.doReject);
				$('BTN_export').observe('click', buttons.doExport);
				$('BTN_updateNote').observe('click', buttons.doUpdateNote); <%-- 新增備註 --%> <%-- [20211007]新增程式碼 --%>
				$('CHARGEID').observe('change', actions.getUserNameList); <%-- [20210708] 修改件:聯徵公務機關資料查調作業 --%>
				$('CHECK_ITEM').observe('change',actions.buildGrid); <%-- [20210708] 修改件:聯徵公務機關資料查調作業 --%>
				actions.buildGrid('Z50'); <%-- [20210708] 修改件:聯徵公務機關資料查調作業 --%>
				
				var CHARGEID = $('CHARGEID');
				<c:if test="${empty CHARGEID}">
					CHARGEID.disable();
					CHARGEID.options.length = 0;
					alert('作業人員所屬科別不可執行聯徵查詢紀錄查核作業');
				</c:if>
				<c:if test="${nochange eq 'Y'}">
					CHARGEID.disable();
					CHARGEID.removeChild(CHARGEID.options[0]);
				</c:if>
				<%-- [20211007]新增程式碼: BTN_updateNote.disable(); --%>
				<c:if test="${nodeDisabled}">
					$('BTN_updateNote').disable(); <%-- '新增備註'按鈕disable --%> 
				</c:if>
				buttonAuth();
				PageUI.resize();
				displayMessage();
            }
        };
    }

</script>
</head>
<body>
	<form name="form1" id="form1">
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<th colspan="7" align="left">聯徵查詢紀錄查核作業</th>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" >查核項目</td> <%-- [20210708] 修改件:聯徵公務機關資料查調作業  --%>
				<td class="tbYellow2" width="35%" >
					<select id="CHECK_ITEM" name="CHECK_ITEM" title="查核項目" class="textBox2">
						<c:forEach var="map" items="${CHECK_ITEM_LIST}">
				 			<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" >查詢起日</td>
				<td class="tbYellow2" >
					<input id="STAQDATE" name="STAQDATE" title="查詢起日" datatype="ROCDate" type="text" class="textBox2" size="15" maxlength="9" value="${STAQDATE}">
				</td>
				<td class="tbYellow2" align="center" rowspan="3" width="10%" >
					<button type="button" id="BTN_query" class="button">查詢</button>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" >承辦科別</td>
				<td class="tbYellow2" width="35%" >
					<select id="CHARGEID" name="CHARGEID" title="承辦科別" class="textBox2">
						<option value="ALL">全部</option>
						<c:forEach var="map" items="${CHARGEID}">
				 			<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
					<select id="USERNAME" name="USERNAME" title="承辦人員" class="textBox2">
						<option value="">全部</option>
					</select>
				</td>
				<td class="tbYellow" >查詢迄日</td>
				<td class="tbYellow2" >
					<input id="ENDQDATE" name="ENDQDATE" title="查詢迄日" datatype="ROCDate" type="text" class="textBox2" size="15" maxlength="9" value="${ENDQDATE}">
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" >查詢進度</td>
				<td class="tbYellow2" width="35%" colspan="3">
					<select id="QPROC" name="QPROC" title="查詢進度" class="textBox2">
						<option value="">全部</option>
						<c:forEach var="map" items="${QPROC_LIST}">
				 			<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>			
			<tr>
				<td class="tbYellow2" align="center" colspan="5">
					<button type="button" id="BTN_save" class="button">儲存</button>
					<button type="button" id="BTN_check" class="button">查核確認</button>
					<button type="button" id="BTN_boss" class="button">主管覆核</button>
					<button type="button" id="BTN_reject" class="button">退回</button>
					<button type="button" id="BTN_export" class="button">匯出csv檔</button>
					<button type="button" id="BTN_updateNote" class="button">新增備註</button>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%" >備註</td>
				<td class="tbYellow2" width="35%" colspan="3">
					<textarea id="NOTE" name="NOTE" cols="50" rows="2" maxlength="100"></textarea>
				</td>
			</tr>
		</table>
	</form>
	<table id="grid" class='grid'></table>
</body>
</html>
