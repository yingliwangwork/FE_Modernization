<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5" %>
<%@ page import="java.net.URLDecoder"%>
<!--
程式：DSA30200.jsp
作者：簡睿甫
功能：鑑價資料查詢
完成：

[20210621] 黃柏堯 新增智能件流程進度欄位
[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%>
<fmt:setBundle basename="TextResource" />
<title></title>

<!--匯入外部Javascript 與 css, 新增請放下面-->
<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />

<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/prototype.js"></script>  <%-- JS基礎底層必備用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>    <%-- CSR相關處理用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>   <%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/TableUI.js"></script>      <%-- 表格用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/PageUI.js"></script>       <%-- 標準外框表格 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/calendar.js"></script>        <%-- 日曆用 --%>	
<script type="text/javascript" src="<%=htmlBase%>/CM/js/date.js"></script>            <%--日期用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>   <%-- 開新視窗 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>            <%-- 下載 匯出 列印用 --%>

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

Event.observe(window, 'load', new DSA30200().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSA30200(){
	var grid;
	var grid_D;
	var grid_E;
	
	var APPLY_ID = '<c:out value="${APPLY_ID}" default="" escapeXml="false" />';
	
	var APPR_NAME = <c:out value="${APPR_NAME}" default="[]" escapeXml="false" />;
	var AUTO_CAPT_ID_GROUP_LIST = <c:out value="${AUTO_CAPT_ID_GROUP_LIST}" default="[]" escapeXml="false" />;
	var rtnList = <c:out value="${rtnList}" default="[]" escapeXml="false" />;
	// 檔案名稱string[]
	var fileName = [ {FILE_NAME: "土地謄本"},{FILE_NAME: "建物謄本"}, {FILE_NAME:"地籍圖"}, {FILE_NAME:"建物測量成果圖"}, {FILE_NAME:"買賣契約"}];
	var BORROW_NAME_ID_complete;

	//-----------------------------------------------------
	//IM AJAX 國內共用
	//-----------------------------------------------------
	function ajaxPostIM( actionName, params, successAction, errorFunction ){
		new Ajax.Request(
			"<%=dispatcher%>/DSA3_0200/" + actionName, 
			{ parameters : params ,
			  onSuccess : function (response) {
				var resp = response.responseJSON;
				if(CSRUtil.isSuccess(resp)){      
					successAction(resp);
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			 }
		});
	}
	
	var button = {
		// 查詢
		doQuery: function() {
		
			// 清空檢核
			validates.clear();
			// 檢核觸動：所有檢核設定要在觸動前完成
			if(!validates.valid.validate()){ 
				return; 
			}
			
			ajaxPostIM( 'query' ,  {Form: Object.toJSON($('form').serialize(true))}, 
				function(resp){	
					var rtnList = resp.rtnList;
					grid.load(rtnList || []); 
					
					grid_D.load([]);
					grid_E.load([]);
					
					button.doClearBlockC();
					button.doClearBlockF();
					button.doClearBlockG();
					
					//	保留參數管理-更新受理編號
					APPLY_ID = $F('APPLY_ID');
					if(APPLY_ID) {
						CSRUtil.keepParamsManager.put({'APPLY_ID':APPLY_ID});
					}
					
					if(rtnList &&　rtnList.length == 1) {
						button.doForOneRecord(rtnList[0]);
					}
				},
				function(resp){			
					grid.load([]); 
					
					grid_D.load([]);
					grid_E.load([]);
					
					button.doClearBlockC();
					button.doClearBlockF();
					button.doClearBlockG();
				}				
			);	
		},
		
		// 清除
		doClear: function(){
			form.reset();
			var APPR_ID = $('APPR_ID'); 
			APPR_ID.update(APPR_ID.firstDescendant('option'));
		},
		
		// 列印
		doPrint: function(){
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料");  
				return;
			}
		
			var queryData = [];
			for(var i =0; i< records.length; i++) {
				queryData.push({
					APPLY_ID: records[i]['APPLY_ID']
				});			
			}
			
			window.open("", "DSA3_0201", "top=50, left=50,  toolbar=no, resizable=yes, location=0, status=0, scrollbars=1, titlebar=0, width=800, height=600");
			
			var url = "<%=dispatcher%>/DSA3_0201/prompt";			
			var form = $('form');
			form.target='DSA3_0201';
			form.action=url;
			$('BORROW_NAME_ID_COMPLETE').value = BORROW_NAME_ID_complete;
			$('queryData').value = Object.toJSON(queryData);		
			form.submit();	
		},
		
		// 路徑規劃
		doPath: function(){
			var records = grid.getCheckedRecord();
			if(records.length == 0){
				alert("請至少選取一筆資料");  
				return;
			}
			
			ajaxPostIM( 'path' ,  {chkList: Object.toJSON(records)}, 
				function(resp){	
					window.open(resp.MapUrl, "DSA3_0200");
				},
				function(resp){	
				}
			);
		},
		
		// 鑑價組 連動 鑑價人員 
		doGearing: function() {
			var APPR_ID = $('APPR_ID');
			APPR_ID.update(APPR_ID.firstDescendant('option'));
			//20210723 覆核人員查詢條件
			var AUTO_CAPT_ID = $('AUTO_CAPT_ID');
			
			AUTO_CAPT_ID.update(AUTO_CAPT_ID.firstDescendant('option'));
			var EMPList = APPR_NAME[$F('APPR_GROUP')];
			if(EMPList) {
				for(var i =0; i<EMPList.length;i++ ) {
					var node  = new Element('option',
						{ value: EMPList[i].ID }
					).update(EMPList[i].NAME);
					
					APPR_ID.appendChild(node);
				}
				//智能件選項
				var node  = new Element('option',
						{ value: "DSA3_B200" }
					).update("智能件");
					APPR_ID.appendChild(node);
				var node2  = new Element('option',
						{ value: "DSA3_B200" }
					).update("智能件");
					APPR_ID.appendChild(node);
					AUTO_CAPT_ID.appendChild(node2);
			}
			//覆核人員 20211221 智能後續優化 上傳維護組長名單 鑑價資料查詢畫面(DSA30200)-覆核人員下拉選單
			for(var i =0; i<AUTO_CAPT_ID_GROUP_LIST.length;i++ ) {
				if (AUTO_CAPT_ID_GROUP_LIST[i].APPR_GROUP==$F('APPR_GROUP')){
					var node2  = new Element('option',
							{ value: AUTO_CAPT_ID_GROUP_LIST[i].ID }
						).update(AUTO_CAPT_ID_GROUP_LIST[i].NAME);
					AUTO_CAPT_ID.appendChild(node2);
				};
				
			}
		},
		
		// 土地資料標頭"最新年公告現值"、"前次移轉現值"，依資料更新
		//doLandTitleUpdate: function( ANNOU_YEAR, TRAN_YM) {
		//	$('grid_D').select("th[name='FANNOU_VALUE']").each( function(td) {
		//		var a = td.down('a');
		//		td.update("最新"+ ANNOU_YEAR + "年公告現值");
		//		td.appendChild(a);
		//	});
		//	$('grid_D').select("th[name='FTRAN_VALUE']").each( function(td) {
		//		var a = td.down('a');
		//		td.update("前次"+ TRAN_YM + "移轉現值");
		//		td.appendChild(a);
		//	});
		//},
		
		// C區資料植入
		dofillupBlockC: function(bankfileList) {
			if(bankfileList) {
				$('BANK_FILE').update();
				for(var i = 0; i < bankfileList.length ; i++) {
					if( $('BANK_FILE').innerHTML.length > 0) {
						var span = new Element('span').update('、');
						$('BANK_FILE').appendChild(span);
					}				
				
					var bankfile = bankfileList[i];
					var link = new Element('a',
					{ href: '#' , attachPath : bankfile['ATTACH_PATH']}).update(bankfile['ATTACH_NM']).observe('click',
						function(e) {
							var target = e.target;
							var toAttachPath = target.getAttribute("attachPath");
							//RPTUtil.download({'downloadFileName': bankfile['ATTACH_NM'], 'downloadFileFullPath': bankfile['ATTACH_PATH']});
							if (toAttachPath.indexOf("http") < 0) {
								RPTUtil.downloadFile('${dispatcher}/DSA3_0200/download', {'downloadFileName': bankfile['ATTACH_NM'], 'downloadFileFullPath': toAttachPath}, true);
							} else {
								window.open(target.getAttribute("attachPath"));
							}
						});
					$('BANK_FILE').appendChild(link);
				}
			} else {
				$('BANK_FILE').innerHTML = '';
			}		
		},
		
		// ELAND區資料植入
		dofillupBlockELAND: function(eLandFileList) {
			if(eLandFileList) {
				$('ELAND_FILE').update();
				for(var i = 0; i < eLandFileList.length ; i++) {
					if( $('ELAND_FILE').innerHTML.length > 0) {
						var span = new Element('span').update('、');
						$('ELAND_FILE').appendChild(span);
					}				
				
					var eLandfile = eLandFileList[i];
					var link = new Element('a',
					{ href: '#' , attachPath : eLandfile['ATTACH_PATH']}).update(eLandfile['ATTACH_NM']).observe('click',
						function(e) {
							var target = e.target;
							window.open(target.getAttribute("attachPath"));
						});
					$('ELAND_FILE').appendChild(link);
				}
			} else {
				$('ELAND_FILE').innerHTML = '';
			}		
		},
		
		// F區資料植入
		dofillupBlockF: function(otherMap) {
			if(otherMap) {
				$('block_F').select('td[class="tbYellow2"]').each( function(td) {
					var id = td.id;
					if(id == "TRADE_DATE" && otherMap['TRADE_DATE']) {
						td.update(Date.toInputROC(otherMap['TRADE_DATE'], '/'));
					} else if (id == "APPR_PIC_DATE" && otherMap['APPR_PIC_DATE']) {
						td.update(Date.toInputROC(otherMap['APPR_PIC_DATE'], '/'));
					} else if (id == "APPEARANCE_PIC_DATE" && otherMap['APPEARANCE_PIC_DATE']) {
						td.update(Date.toInputROC(otherMap['APPEARANCE_PIC_DATE'], '/'));
					} else {
						td.update(otherMap[id]);
					}
				});
				
				if(otherMap['PIC_APPLY_ID']) {				
					var PIC_APPLY_ID = otherMap['PIC_APPLY_ID'];
					var url1;
					if (PIC_APPLY_ID.substring(3,5)=='@A' || PIC_APPLY_ID.substring(3,5)=='@I' || PIC_APPLY_ID.substring(3,5)=='@J') {
						url1 = '<%=dispatcher%>/DSA3_0600/prompt';
					} else if (PIC_APPLY_ID.substring(3,5)=='@B' || PIC_APPLY_ID.substring(3,5)=='@U' || PIC_APPLY_ID.substring(3,5)=='@V') {
						url1 = '<%=dispatcher%>/DSA3_0700/prompt';
					} else {
						url1 = '<%=dispatcher%>/DSA3_0500/prompt';
				 	}
				 	//產生超連結
					var link = new Element('a',
					{ href: '#'}).update(PIC_APPLY_ID).observe('click',
						function() {
							popupWin.windowOpen( url1 ,
							{
								'parameters': {'APPLY_ID': PIC_APPLY_ID},
								'fullScreen': false,
								'attributes': {'resizable': 'yes'}
							});
						});
					$('PIC_APPLY_ID').update(link);
				}				
				
				if(otherMap['PIC_COMMUNITY_NO']) {	
					var PIC_COMMUNITY_NO = otherMap['PIC_COMMUNITY_NO'];
					var url2 = '<%=dispatcher%>/DSA3_3310/prompt';
					//產生超連結
					var link = new Element('a',
					{ href: '#'}).update(PIC_COMMUNITY_NO).observe('click',
						function() {
							popupWin.windowOpen( url2 ,
							{
								'parameters': {'COMMUNITY_NO': PIC_COMMUNITY_NO},
								'fullScreen': false,
								'attributes': {'resizable': 'yes'}
							});
						}
					);	
					$('PIC_COMMUNITY_NO').update(link);
				}
				
				$('APPLY_ID_F').update(otherMap['APPLY_ID']);
				if(otherMap['TRADE_PRICE']) {
					$('TRADE_PRICE').update(button.formatValue(null,otherMap['TRADE_PRICE']) + '萬');
				}
				
				if(otherMap.TRADE_CODE == 2) {
					$('LOAN_TYPE_NM').update((otherMap.LOAN_TYPE_NM || "") +'<span style="color:red;">法拍</span>');
				} else {
					$('LOAN_TYPE_NM').update(otherMap.LOAN_TYPE_NM);
				}
				
				if (otherMap.ELITE_AGENT != "") {	
					$('BORROW_NAME_ID').update(otherMap.BORROW_NAME_ID +'<span style="color:red;"><b> '+otherMap.ELITE_AGENT+'</b></span>');
					BORROW_NAME_ID_complete = otherMap.BORROW_NAME_ID + ' ' + otherMap.ELITE_AGENT;
				} else {
					$('BORROW_NAME_ID').update(otherMap.BORROW_NAME_ID);
					BORROW_NAME_ID_complete = otherMap.BORROW_NAME_ID;
				}							
				
				$('DAY_TEL').update( (otherMap.DAY_TEL_AREA || "") + '-'+ (otherMap.DAY_TEL_NUM || "") + '-'+ (otherMap.DAY_TEL_EXT || ""));
				$('NIGHT_TEL').update( (otherMap.NIGHT_TEL_AREA || "") + '-'+ ( otherMap.NIGHT_TEL_NUM || "") + '-'+ (otherMap.NIGHT_TEL_EXT || ""));
				$('CON_ADDR').update( (otherMap.CON_ZIP || "")+ (otherMap.CON_ADDR || ""));
				$('COM_TEL').update((otherMap.COM_TEL_AREA || "") + '-' + (otherMap.COM_TEL_NUM  || "")+ '-' + (otherMap.COM_TEL_EXT || ""));
				$('SPC_CODE').update( (otherMap.SPC_CODE_NM || "")+ (otherMap.SPC_DESC || "") );
			}		
		},
		
		// G區資料植入
		dofillupBlockG: function(rpaMap) {
			if(rpaMap) {
				$('block_G').select('td[class="tbYellow2"]').each( function(td) {
					var id = td.id;
					td.update(rpaMap[id]);
				});
			}		
		},
		
		// 超連結 "土地、建物謄本影像"
		doLink: function(APPLY_ID) {
			//產生超連結
			var link_new = new Element('a',
			{ href: '#'}).update("土地、建物謄本影像(新版)").observe('click',
				function() {
					popupWin.windowOpen('<%=dispatcher%>/DSA0_0200/prompt',{
						'parameters': {'APPLY_ID': APPLY_ID},
						'fullScreen': false,
						'attributes': {'resizable': 'yes'}
					});
				});
			$('IMG_NEW').update(link_new);
			
			var link_old = new Element('a',
			{ href: '#'}).update("土地、建物謄本影像(舊版)").observe('click',
				function() {
					popupWin.windowOpen('<%=dispatcher%>/DSA0_0100/prompt',
						{
							'parameters': {	'APPLY_ID': APPLY_ID,    //受理編號
											'FILE_NAME':Object.toJSON(fileName)//檔案名稱string[]
							}
						});
				});
			$('IMG_OLD').update(link_old);

		},
		
		// 清空C區資料
		doClearBlockC: function() {
			$$('#block_C .tbYellow2').each(function(td) {
				td.update();
			});
		},
		
		// 清空F區資料
		doClearBlockF: function() {
			$$('#block_F .tbYellow2').each(function(td) {
				td.update();
			});
		},
		
		// 清空G區資料
		doClearBlockG: function() {
			$$('#block_G .tbYellow2').each(function(td) {
				td.update();
			});
		},
		
		// 單一資料處理方式: 1. RADIO自動點選 2. 明細自動呈現
		doForOneRecord: function(record) {
			$$('#grid input[type=radio]').each(function(input) {
				input.checked = true;
			});
			
			$('BORROW_NAME').update(record.BORROW_NAME);
			$('BORROW_NAME_ID').update(record.BORROW_NAME_ID);
							
			ajaxPostIM( 'queryDetail' , { rtnMap : Object.toJSON(record) }, 
				function(resp){
					// C區資料植入
					button.dofillupBlockC(resp.bankfileList);
					button.dofillupBlockELAND(resp.eLandFileList);
					button.doLink(record.APPLY_ID);
					
					var landList = resp.landList;
					// 土地資料標頭"最新'ANNOU_YEAR'年公告現值"、"前次'TRAN_YM'移轉現值"，依資料更新
					//if(landList) {
					//	button.doLandTitleUpdate(landList[0]['ANNOU_YEAR'], landList[0]['TRAN_YM']);
					//}
					grid_D.load(landList || [], resp.totalSum, "", ""); 
					grid_E.load(resp.buildList || [], resp.buildTotalSum, resp.subSumList, "");
					
					// F區資料植入
					button.dofillupBlockF(resp.otherMap);
					// G區資料植入
					button.dofillupBlockG(resp.rpaMap);
					
					$('block_C').show();
					$('block_D').show();
					$('block_E').show();
					$('block_F').show();
					$('block_G').show();
					
					PageUI.resize();
				},
				function(resp){	
					grid_D.load([]); 
					grid_E.load([]); 
				}				
			);
		},
		
		// 數字欄位格式
		pattern : '#,###.###', 
		
		// 數字欄位處理(三位一撇)
		formatValue : function(record, value) {
			if(Object.isNumber(value)) {
				return value ? CSRUtil.$fmt(value, button.pattern) : '';
			} else {
				return value ?  value : '';
			}
		}
	};
	
	var validates = {
		initValidation : function() {
			// 欄位檢核
			validates.valid = new Validation("form", { mode:'validator'} );	
			Validation.addAllThese( [
				// 輸入欄位長度及資料型態檢核
				['length-check', '欄位長度有誤',
					function( v,ele,info ) {
						if( v && v.length != ele.maxLength) {
							return false
						}
						return true;
					}
				],
				
				// 受理編號與地址路名門牌需擇一輸入
				['choose-one', '鑑價組別、受理編號需擇一輸入',
					function( v,ele,info ) {
						if( $F('APPLY_ID') || (v || $F('APPR_ID'))) {
							return true;
						}
						$('APPLY_ID').style.backgroundColor = "#FF8888";
						return false;
					}
				],
				
				// 受理編號沒輸入，必須選擇受理進度，且受理進度必須小於鑑價覆核(50),否則顯示錯誤訊息:“請選擇鑑價核覆以前的受理進度!”
				['if-choose-one', '請選擇鑑價核覆以前的受理進度!',
					function( v,ele,info ) {
						if( !$F('APPLY_ID') ) {
							if( v && v < 50 ) {
								return true;
							}else {
								$('APPLY_ID').style.backgroundColor = "#FF8888";
								return false;									
							}
							
						} else {
							return true;
						}
					}
				]
			] );
		}, 
		
		clear: function() {
			// 清空檢核
			validates.valid.clear();
			$('APPLY_ID').style.backgroundColor = "";
		}
	};
	
	return {
		initApp : function() {
		
			PageUI.createPageWithAllBodySubElement( "DSA30200" , "鑑價作業", "鑑價資料查詢" );
			
			grid = new TableUI(
				{table: $("grid"), allSortable: true, pageSize: 8, whenDataNull:'', autoCheckBox:{type:'checknox', isSelectAll: true, insertPosition: 1, text: '列印選取' },
				column:[
					{header:"選取",key:"radio",
						input: {
							type: 'radio',
							action: function( node , dataObj , textDiv, orgData ) {
								$('BORROW_NAME').update(dataObj[0].BORROW_NAME);
								$('BORROW_NAME_ID').update(dataObj[0].BORROW_NAME_ID);
								
								ajaxPostIM( 'queryDetail' , { rtnMap : Object.toJSON(dataObj[0]) }, 
									function(resp){	
										// C區資料植入
										button.dofillupBlockC(resp.bankfileList);
										button.dofillupBlockELAND(resp.eLandFileList);
										button.doLink(dataObj[0].APPLY_ID);
										
										var landList = resp.landList;
										// 土地資料標頭"最新'ANNOU_YEAR'年公告現值"、"前次'TRAN_YM'移轉現值"，依資料更新
										//if(landList) {
										//	button.doLandTitleUpdate(landList[0]['ANNOU_YEAR'], landList[0]['TRAN_YM']);
										//}
										grid_D.load(landList || [], resp.totalSum, "", ""); 

										grid_E.load(resp.buildList || [], resp.buildTotalSum, resp.subSumList, "");
										
										// F區資料植入
										button.dofillupBlockF(resp.otherMap);
										// G區資料植入
										button.dofillupBlockG(resp.rpaMap);

										$('block_C').show();
										$('block_D').show();
										$('block_E').show();
										$('block_F').show();
										$('block_G').show();
										
										PageUI.resize();
									},
									function(resp){	
										grid_D.load([]); 
										grid_E.load([]); 
									}				
								);	
							
							}
						}
					},
					{header:"受理編號",key:"APPLY_ID",
						render:function(record, value){
							CSRUtil.keepParamsManager.put({'APPLY_ID': record.APPLY_ID });
							var alink = document.createElement("a");
							alink.href = "#";
							alink.innerHTML = record.APPLY_ID;
							alink.onclick = function(){
								var form = $("form1");
								var url;
								if (record.IS_AUTOAPPR =='2'){//，20210723 若案件為智能件，點選受理編號超連結，需到簡易鑑價覆核畫面
									url = "<%=dispatcher%>/DSA3_0500/prompt?OP=2&APPLY_ID="+record.APPLY_ID;
								}
								else if (record.APPLY_ID.substring(3,5)=='@A' || record.APPLY_ID.substring(3,5)=='@I' || record.APPLY_ID.substring(3,5)=='@J') {
					 				url = "<%=dispatcher%>/DSA3_0600/prompt?OP=1&APPLY_ID="+record.APPLY_ID;
				 				} else if (record.APPLY_ID.substring(3,5)=='@B' || record.APPLY_ID.substring(3,5)=='@U' || record.APPLY_ID.substring(3,5)=='@V') {
					 				url = "<%=dispatcher%>/DSA3_0700/prompt?OP=1&APPLY_ID="+record.APPLY_ID;
				 				} else {
					 				url = "<%=dispatcher%>/DSA3_0500/prompt?OP=1&APPLY_ID="+record.APPLY_ID;
				 				}
				 				window.location = url;
							};
							return alink;
						}
					},

					{header:"郵遞區號",key:"GAGE_ZIP"},
					{header:"鑑價組",key:"APPR_GROUP_NM"},
					{header:"鑑價人員/覆核人員",key:"APPR_NM", styles: {'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render:function(rec,val){
							var IS_AUTOAPPR = rec.IS_AUTOAPPR;
							if(IS_AUTOAPPR ==2){
								return rec.CFM_NM ||'';//覆核人員
							}
							return val||'';//鑑價人員
						}
					},
					{header:"受理日期",key:"APPLY_DATE"},
					{header:"派件日期",key:"ASSIGN_DATE",
                        render:function(record, value){
                            var REASSIGN_DATE = record.REASSIGN_DATE;
                            return REASSIGN_DATE ? REASSIGN_DATE : (value ? value : '');
                        }
                    },
                    //[20210621] 修改件 新增智能件流程進度欄位
                    {header:"智能流程進度",key:"IS_AUTOAPPR",
                    	render:function(record){
                    		var IS_AUTOAPPR = record.IS_AUTOAPPR;
                    		if (IS_AUTOAPPR == 1){
                    			return "部分完成";
                    		} else if (IS_AUTOAPPR == 2){
                    			return "完成";
                    		} else if (IS_AUTOAPPR == 3){
                    			return "退回"; //[智能流程後續優化 20211221] 「智能件退件」 改為「退回」
                    		} else if (IS_AUTOAPPR == null || IS_AUTOAPPR == ''){
                    			return "不適用"
                    		}                  			
                    	}
                    },
					{header:"受理進度",key:"APPLY_PROCESS_NM"},
					{header:"RPA分區更新",key:"USE_SECT_UPD_STATUS_NM"},
					{header:"地址",key:"ADDR_NO", styles:{'font-family':'EUDC'}}<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				]
			});

			// 土地資料
			grid_D = new TableUI({
				table: $("grid_D"), 
				allSortable: true, 
				pageSize: 10, 
				whenDataNull:'', 
				split: ["NAME"], 
				title:'土地資料', 
				overDiv: false,
				column:[
					{header:"抵押土地座落[地號]",key:"LOCATION", styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render: function(rec, v) {
							return v + '<br>[ ' + rec.LAND_NO1 + '-'+ rec.LAND_NO2 +' ]</br>';
						}
					},
					{header:"土地面積(平方公尺)",key:"LAND_MEASURE",
						render: button.formatValue
					},
					{header:"持分坪數",key:"HOLD_MEASURE",
						render: button.formatValue
					},
					{header:"最新公告年度/現值",key:"FANNOU_VALUE",
						render: function(rec, v) {
							return rec.ANNOU_YEAR + ' / ' + CSRUtil.$fmt(rec.FANNOU_VALUE,'#,###.###');
						}
					},
					{header:"前次移轉年月/現值",key:"FTRAN_VALUE",
						render: function(rec, v) {
							return rec.TRAN_YM + ' / ' + CSRUtil.$fmt(rec.FTRAN_VALUE,'#,###.###');
						}
					},
					{header:"所有權人",key:"NAME", styles:{'font-family':'EUDC'}},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					{header:"持分",key:"HOLD",
						render: function(rec, v) {
							return rec.HOLD_UP + '/' + rec.HOLD_BASE;
						}
					},
					{header:"使用分區",key:"USE_SECT_NM"},
					{header:"使用地類別",key:"USE_KIND_NM"},
					{header:"地目",key:"LAND_POS_NM"}
				]
			});
			
			// 建物資料，為達成GROUP KEY的狀態，又因GRUOP KEY是以行為基準，對於折行無效，所以以偽裝方式進行
			grid_E = new TableUI({
				table: $("grid_E"), 
				allSortable: true, 
				pageSize: 10, 
				whenDataNull:'', 
				split: ["ADDR_NO"], 
				title:'建物資料', 
				overDiv: false,
				column:[
					{header:"房屋門牌號碼[建號]",empty: "rowSpan_down" },
					{header:"建物面積(平方公尺)",empty: "rowSpan_down" },
					{header:"持分坪數",empty: "rowSpan_down" },
					{header:"第幾層/總層數",empty: "rowSpan_down" },
					{header:"持分",empty: "rowSpan_down" },
					{header:"隱藏的群組資料",key:"BUILD_NO" , attrs:{rowSpan:2} , groupKey:["BUILD_NO"]},
					{header:"所有權人",key:"ADDR_NO", groupKey:["BUILD_NO","ADDR_NO"], styles:{'font-family':'EUDC'},<%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						render: function(rec, v) {
							if(rec.LASTLINE) {
								return v;
							}
							return v + '<br>[ ' + rec.BUILD_NO +' ]</br>';
						}
					},
					{header:"建築結構",key:"MEASURE",
						render: button.formatValue
					},
					{header:"登記用途",key:"HOLD_MEASURE",
						render: button.formatValue
					},
					{header:"建築完成日期",key:"FLOOR_NM"},
					{header:"屋齡",key:"HOLD_UP"}
				
				
				/*
					{header:"房屋門牌號碼[建號]",key:"ADDR_NO", groupKey:["ADDR_NO"] ,
						render: function(rec, v) {
							return v + '<br>[ ' + rec.BUILD_NO1 + '-'+ rec.BUILD_NO2 +' ]</br>';
						}
					},
					{header:"建物面積",key:"MEASURE",
						render: button.formatValue
					},
					{header:"持分坪數",key:"HOLD_MEASURE",
						render: button.formatValue
					},
					{header:"第幾層/總層數",key:"FLOOR_NM"},
					{header:"持分",key:"HOLD_UP",
						render: function(rec, v) {
							return rec.HOLD_UP + '/' + rec.HOLD_BASE;
						}
					},
					{header:"所有權人",empty: "rowSpan_up" },//,key:"BUILD_NAME"},
					{header:"建築結構",empty: "rowSpan_up" },//,key:"MATERIAL_NM"},
					{header:"登記用途",empty: "rowSpan_up" },//,key:"MAIN_USE_NM"},
					{header:"建築完成日期",empty: "rowSpan_up" },//,key:"FINISH_DATE_NM"},
					{header:"屋齡",empty: "rowSpan_up" }//,key:"BUILD_AGE"}
					
					*/
					
					
				]
				,pageChange:function(){
					$$("#grid_E td[name=BUILD_NO]").each( function(elem){ elem.style.display='none'; });
				}
			});
			$$("#grid_E th[name=BUILD_NO]").each( function(elem){ elem.style.display='none'; });
			
			// 保留參數管理-取得受理編號
			//if(!APPLY_ID) {
			//	APPLY_ID = CSRUtil.keepParamsManager.get('APPLY_ID');
			//}
			
			// 檢核初始化
			validates.initValidation();
			
			// C、D、E、F區初始隱藏
			$('block_C').hide();
			$('block_D').hide();
			$('block_E').hide();
			$('block_F').hide();
			$('block_G').hide();
			
			if('${APPR_ID}'!=''){
				$('APPR_ID').value = '${APPR_ID}';
			}
			
			$('APPLY_PROCESS').value = '0';

			if(APPLY_ID) {
				$('APPLY_ID').value = APPLY_ID;
				button.doQuery();
			}
			
			if(rtnList){
				grid.load(rtnList || []); 
			}
					
			// 監聽: 查詢
			$("btn_query").observe('click', button.doQuery );	
			
			// 監聽: 清除
			$("btn_clear").observe('click', button.doClear );	
			
			// 監聽: 列印
			$("btn_print").observe('click', button.doPrint );	
			
			// 監聽: 路徑規劃
			$("btn_path").observe('click', button.doPath );
			
			// 連動監聽: 鑑價組 連動 鑑價人員
			$("APPR_GROUP").observe('change', button.doGearing );
			
			// 監聽: 受理編號轉大寫
			$("APPLY_ID").observe('change', function() {$("APPLY_ID").value = $F("APPLY_ID").toUpperCase();} );	
			
			PageUI.resize();
			autoFormatToDate();
			displayMessage();
		}// end initApp()--
	}// end return--
}// end DSA33100
</script>
</head>


<body bgcolor="#F0FBC6" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
	<form id="form">
	<input type="hidden" id="queryData" name="queryData" value="">
	<input type="hidden" id="BORROW_NAME_ID_COMPLETE" name="BORROW_NAME_ID_COMPLETE" value="">
	<table id='block_A' width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
		<tbody>
			<tr>
				<td class="tbYellow" id="APPLY_ID_NM" >受理編號</td>
				<td  class="tbYellow2">
					<input name="APPLY_ID" id="APPLY_ID" type="text" class="textBox2 length-check" size="15" maxlength="11" value="" >
				</td>
				<td class="tbYellow">鑑價組</td>
				<td  class="tbYellow2" >
					<select id="APPR_GROUP" name="APPR_GROUP" class="choose-one" >
						<option value="">全部</option>
						<c:forEach var="map" items="${APPR_GROUP_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>
					</select> 
				</td>
				<td class="tbYellow">鑑價人員</td>
				<td  class="tbYellow2">
					<select id="APPR_ID" name="APPR_ID" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						<option value="">全部</option>				
						<c:forEach var="map" items="${APPR_ID_LIST}">
							<option value="${map.ID}">${map.NAME}</option>
						</c:forEach>
					</select> 				
				</td>
				<td class="tbYellow">覆核人員</td>
				<td  class="tbYellow2">
					<select id="AUTO_CAPT_ID" name="AUTO_CAPT_ID" alt="ch"><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
						<option value="">全部</option>				
						<c:forEach var="map" items="${AUTO_CAPT_ID_LIST}">
							<option value="${map.ID}">${map.NAME}</option>
						</c:forEach>
					</select> 				
				</td>
				<td class="tbYellow2"  rowspan='2' align="center" >
					<input id="btn_query" type="button" value='查詢' class="button"> 
					<input id="btn_clear" type="button" value='清除' class="button"> 			
					<input id="btn_print" type="button" value='列印' class="button"> 		
					<input id="btn_path" type="button" value='路徑規劃' class="button">	
				</td>				
			</tr>
			<tr>
				<td class="tbYellow">派件日期</td>
				<td  class="tbYellow2">
					<input name="ASSIGN_DATE" id="ASSIGN_DATE" datatype="ROCDate" type="text" 	class="textBox2  validate-ROCDate" size="12" maxlength="7" value="${LAST_MONTH}"> 
					<img src="<%=imageBase%>/CM/cal.gif" alt="Date" 	onclick="getCalendarFor($('ASSIGN_DATE'))">			
				</td>
				<td class="tbYellow">受理進度</td>
				<td  class="tbYellow2" colspan="5" >
					<select id="APPLY_PROCESS" name="APPLY_PROCESS" class="if-choose-one">
						<option value="">全部</option>		
						<option value="0">處理中</option>
						<c:forEach var="map" items="${APPLY_PROCESS_LIST}" >
							 <option value = "${map.key}"> ${map.value} </option>
						</c:forEach>						
					</select> 				
				</td>				
			</tr>			
		</tbody>	
	</table>
	</form>
	<table id='grid'></table>
	<!-- 附檔資料 -->
	<div id='block_C'>
		<table  width="100%" border="0" cellspacing="0" cellpadding="0" class="tbBox2">
			<tbody>
				<tr>
					<td class="tbYellow" width="12%" >借款人</td>
					<td class="tbYellow2" id="BORROW_NAME"  width="15%" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" width="10%" >影像</td>
					<td class="tbYellow2" id="IMG_NEW" width="25%"></td>
					<td class="tbYellow2" id="IMG_OLD"></td>		
				</tr>
				<tr>
					<td class="tbYellow" >銀行附件檔案</td>
					<td class="tbYellow2" id="BANK_FILE" colspan="4"></td>				
				</tr>
				<tr>
					<td class="tbYellow" >電子謄本檔案</td>
					<td class="tbYellow2" id="ELAND_FILE" colspan="4"></td>				
				</tr>
			</tbody>	
		</table>
	</div>
	<!-- 土地資料 -->
	<div id='block_D'>
		<table id='grid_D'></table>
	</div>
	<!-- 建物資料 -->
	<div id='block_E'>
		<table id='grid_E'></table>
	</div>
	<!-- 其他資料 -->
	<div id='block_F'>
		<table  width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
			<tbody>
				<tr>
					<td colspan='6' class="tbYellow0" align='center' vlign='center' >
						<b>其他資料</b>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >受理編號</td>
					<td class="tbYellow2" id="APPLY_ID_F" width="16%" ></td>
					<td class="tbYellow" width="16%" >買賣金額</td>
					<td class="tbYellow2" id="TRADE_PRICE" width="16%" ></td>
					<td class="tbYellow" width="16%" >買賣日期</td>
					<td class="tbYellow2" id="TRADE_DATE"></td>				
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >貸款類別</td>
					<td class="tbYellow2" id="LOAN_TYPE_NM" width="16%" ></td>
					<td class="tbYellow" width="16%" >經辦</td>
					<td class="tbYellow2" id="CRED_NM"  width="16%" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" width="16%" >經辦電話</td>
					<td class="tbYellow2" id="CRED_TEL"></td>				
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >客戶服務單位</td>
					<td class="tbYellow2" id="SERV_NAME" width="16%" ></td>
					<td class="tbYellow" width="16%" >總租金/總押金</td>
					<td class="tbYellow2" id="RENTAL_DEPOSIT"></td>	
					<td class="tbYellow" width="16%" >職位</td>
					<td class="tbYellow2" id="JOB_TITLE" ></td>				
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >電話(日)</td>
					<td class="tbYellow2" id="DAY_TEL"  width="16%" ></td>
					<td class="tbYellow" width="16%" >(夜)</td>
					<td class="tbYellow2" id="NIGHT_TEL"  width="16%" ></td>
					<td class="tbYellow" width="16%" >行動電話</td>
					<td class="tbYellow2" id="MOBILE" ></td>				
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >通訊地址</td>
					<td class="tbYellow2" id="CON_ADDR" colspan="5" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >聯絡人單位</td>
					<td class="tbYellow2" id="COM_DIV_NM"   width="16%" ></td>
					<td class="tbYellow" width="16%" >聯絡人姓名</td>
					<td class="tbYellow2" id="COM_NAME" colspan="3" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >聯絡人電話</td>
					<td class="tbYellow2" id="COM_TEL"  width="16%" ></td>
					<td class="tbYellow" width="16%" >聯絡人行動電話</td>
					<td class="tbYellow2" id="COM_MOBIL" colspan="3"></td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >經手人</td>
					<td class="tbYellow2" id="AGENT_NAME"  width="16%" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
					<td class="tbYellow" width="16%" >借款人</td>
					<td class="tbYellow2" id="BORROW_NAME_ID" colspan="3" style="font-family:'EUDC'"></td><%--[20240923] 修改件 陳勁谷 CHROME瀏覽器難字調整_DSA3~A6 --%>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >車位型態/編號</td>
					<td class="tbYellow2" id="PARK" colspan="5" ></td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >※※特殊注意事項</td>
					<td class="tbYellow2" id="SPC_CODE" colspan="5" ></td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >※批價條件</td>
					<td class="tbYellow2" id="APPR_COND_NM"  width="16%" ></td>
					<td class="tbYellow" width="16%" >優惠種類</td>
					<td class="tbYellow2" id="PREFER_TYPE_NM"></td>
					<td class="tbYellow" width="16%" >受理類別</td>
					<td class="tbYellow2" id="APPLY_KIND_NM"></td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" rowspan="2" >案名</td>
					<td class="tbYellow2" id="CASE_NAME"  width="16%" rowspan="2" ></td>
					<td class="tbYellow" width="16%" >前件外觀照日期</td>
					<td class="tbYellow2" id="APPR_PIC_DATE"></td>
					<td class="tbYellow" width="16%" >前件受理編號</td>
					<td class="tbYellow2" id="PIC_APPLY_ID"></td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >社區照片最新日期</td>
					<td class="tbYellow2" id="APPEARANCE_PIC_DATE"></td>
					<td class="tbYellow" width="16%" >社區編號</td>
					<td class="tbYellow2" id="PIC_COMMUNITY_NO"></td>
				</tr>
			</tbody>	
		</table>
	</div>
	<!-- RPA工作區 -->
	<div id='block_G'>
		<table  width="100%" border="0" cellspacing="1" cellpadding="0" class="tbBox2">
			<tbody>
				<tr>
					<td colspan='6' class="tbYellow0" align='center' vlign='center' >
						<b>RPA工作區（無資料或異常，請人工作業）</b>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >列管區</td>
					<td class="tbYellow2" id="RESTRICT_AREA_NM" width="16%" ></td>
					<td class="tbYellow" width="16%" >特殊屋況</td>
					<td class="tbYellow2" id="SPC_CONDITION_STATUS_NM" width="16%"></td>
					<td class="tbYellow" align='center' width="36%" colspan="2">
						<span style="color:red;">※特殊屋況查詢：資料庫尚未洗清完成前，鑑價人員仍須比對資料庫</span>
					</td>
				</tr>
				<tr>
					<td class="tbYellow" width="16%" >土壤液化截圖結果</td>
					<td class="tbYellow2" id="LIQ_PIC_STATUS_NM" width="16%" ></td>
					<td class="tbYellow" width="16%" >使用分區更新結果</td>
					<td class="tbYellow2" id="USE_SECT_UPD_STATUS_NM" width="16%" ></td>
					<td class="tbYellow" width="16%" >使用分區截圖結果</td>
					<td class="tbYellow2" id="USE_SECT_PIC_STATUS_NM"></td>
				</tr>
			</tbody>
		</table>
	</div>
</body>
</html>