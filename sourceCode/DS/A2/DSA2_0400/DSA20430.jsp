<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSA20430.jsp
功能：公務機關查調作業
作者：黃銓盛
完成：2021/2/24

[20210819]問題單號：20210819093447
1.修正畫面顯示
[20210906]問題單號：20210902092017
1.修補需求 葉威揚
[20211007]問題單號：20211006162756
若該筆資料showCheckBox = N，則該筆checkbox disable
[20241106]公務機關查詢作業優化:新增檢核
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
	Event.observe(window, 'load', new DSA20430().initApp);
		
    function DSA20430() {   		
    	var valid1;
    	var grid;
    	var ajaxRequest = new CSRUtil.AjaxHandler.request('${dispatcher}/DSA2_0430/');

    	var cover;
    	var auxiliary = {
    			
    		<%--CoverPage(鎖定畫面)--%>
    		createCoverPage:function(){
    			cover = CSRUtil.createCoverPage('_frontCover');
    			cover.show();
    		},
    		<%--CoverPage(開放畫面)--%>
    		closeCoverPage: function(){
    			cover.hide();
    		}
    	}
    	
    	function initValidation(){
	    	valid1 = new Validation("form1", { focusOnError:true, immediate:false });	
	    	
	    	Validation.addAllThese([
	    		<%--[ 'chkDiffDay1',  '不可大於迄日', 
					function(){ 
						return (diffDay( $F('INPUT_DATE_S') , $F('INPUT_DATE_E') ) >= 0); 
					}
				],
				[ 'chkDiffDay2',  '查詢日期不可為空，且區間不可超過1個月!', 
					function(){ 
						return (diffDay( $F('INPUT_DATE_S') , $F('INPUT_DATE_E') ) < 30); 
					}
				],--%>
				[ 'chkID',  '請輸入有效ID', 
					function(){ 
						<%--[20210906]若選擇【承辦科別】查詢，則不用檢核【查詢方式】是否有輸入。--%>
						if($$('[name="QUERY_TYPE_radio"]')[0].checked){
							return true;
						}
						if("QUERY_ID" == $F('QUERY_TYPE')){
		    				var ID_VALUE = $F('QUERY_TYPE_VALUE');
		    				var ID_len = ID_VALUE.length;
		    				if((ID_VALUE.length==10 && idCheck1(ID_VALUE) == false) || ID_len != 10 || !ID_len){
		    					return false;
		    				}
		    			}
						return true; 
					}
				],
				[ 'chkAPPLY_ID',  '[受理編號]輸入長度不符', 
					function(){ 
						if("APPLY_ID" == $F('QUERY_TYPE')){
		    				var ID_VALUE = $F('QUERY_TYPE_VALUE');
		    				if(ID_VALUE.length!=11){
		    					return false;
		    				}
		    			}
						return true; 
					}
				]
	    	]);
    	}
    	
    	var actions = {
    		set_SectionB : function(reqMap){
    			$('QUERY_T50').checked = false;
    			$('QUERY_T51').checked = false;
    			$('QUERY_T52').checked = false;
    			
    			$('QUERY_DATE_S').setValue(reqMap['QUERY_DATE_S']);
    			$('QUERY_DATE_E').setValue(reqMap['QUERY_DATE_E']);
    			if("Y" == reqMap['QUERY_T50']){
    				$('QUERY_T50').checked = true;
    			}
				if("Y" == reqMap['QUERY_T51']){
					$('QUERY_T51').checked = true;				
				}
				if("Y" == reqMap['QUERY_T52']){
					$('QUERY_T52').checked = true;
				}
    		},
    		getSubmitMap : function(){
    			var reqMap = {};
    			var QUERY_TYPE = $F('QUERY_TYPE');
    			var QUERY_TYPE_VALUE = $F('QUERY_TYPE_VALUE');
    			if('APPLY_ID' == QUERY_TYPE || 'LOAN_ID' == QUERY_TYPE){
    				reqMap['CASE_ID'] = QUERY_TYPE_VALUE;
				}else if('QUERY_ID' == QUERY_TYPE){
					reqMap['QUERY_ID'] = QUERY_TYPE_VALUE;
				}
    			reqMap['fileItem'] = $F('import_file');
    			reqMap['INPUT_CRED_DEPT'] = $F('INPUT_CRED_DEPT');
    			reqMap['QUERY_DATE_S'] = $F('QUERY_DATE_S');
    			reqMap['QUERY_DATE_E'] = $F('QUERY_DATE_E');
    			var FILE_FROM = $F('FILE_FROM');
    			if(FILE_FROM){
    				reqMap['FILE_FROM'] = FILE_FROM;
    				reqMap['AV_FILE_NAME'] = $F('AV_FILE_NAME');
    			}else if(!FILE_FROM && $F('import_file')){
    				reqMap['FILE_FROM'] = '1';
    			}
    			
    			var T50,T51,T52;
    			if($('QUERY_T50').checked){
    				T50 = "Y";
    			}else{
    				T50 = "N";
    			}
    			if($('QUERY_T51').checked){
    				T51 = "Y";
    			}else{
    				T51 = "N";
    			}
    			if($('QUERY_T52').checked){
    				T52 = "Y";
    			}else{
    				T52 = "N";
    			}
    			reqMap['QUERY_T50'] = T50;
    			reqMap['QUERY_T51'] = T51;
    			reqMap['QUERY_T52'] = T52;
    			reqMap['APPLY_FROM'] = "DSA20430";
    			reqMap['STATUS'] = "1";
    			reqMap['QUERY_TYPE'] = "0";
    			reqMap['FILE'] = $F('import_file');
    			return reqMap;
    		},
    		check_BeforeSubmit : function(){
    			<%--[20210906]副檔名檢核--%>
    			var local_file = $F('import_file');
    			var fileName = $('import_file').value||'';
    			if(local_file && fileName.substring(fileName.lastIndexOf(".")+1,fileName.length).toUpperCase()!=='JPEG'){
    				alert("檔案上傳限.jpeg圖檔");
    				return false;
    			}
    			if("Y" != $F('BTN_query')){
    				alert("請先輸入[受理編號]或[貸款帳號]查詢");
    				return false;
    			}
    			var QUERY_TYPE = $F('QUERY_TYPE');
    			if(!("APPLY_ID" == QUERY_TYPE || "LOAN_ID" == QUERY_TYPE) && !$F('QUERY_TYPE_VALUE')){
    				alert("請先輸入[受理編號]或[貸款帳號]查詢");
    				return false;
    			}
    			var file_0431 = $('GET0431_FNAME').innerHTML;
    			if(!local_file && !file_0431){
    				alert("請先選取檔案或影像選取再送出查詢");
    				return false;
    			}
    			if(local_file && file_0431){
    				alert("請選擇其中一個上傳");
    				return false;
    			}
    			if(!isROCdate($('QUERY_DATE_S').value) || !isROCdate($('QUERY_DATE_E').value)){
    				alert("授權起迄日[請輸入正確的民國日期格式]");
    				return false;
    			}
    			<%--[20241107]移除檢核授權區間不可超過3個月(93天) --%>
    			
    			if(!$F('QUERY_T50') && !$F('QUERY_T51') && !$F('QUERY_T52')){
    				alert("授權項目至少勾選一項");
    				return false;
    			}
    			<%--[2022.02.21]優化by詩婷--%>
    			if($F('QUERY_DATE_S') > $F('QUERY_DATE_E') ){
    				alert("授權起日不可大於迄日!");
    				return; 
    			}
    			<%--[20241106]檢核授權起日是否超過今日日期、授權迄日是否超過授權起日+365天 --%>
    			var QUERY_DATE_S = $F('QUERY_DATE_S');
    			if(diffDay(getY2KToday(), QUERY_DATE_S) > 0 || $F('QUERY_DATE_E') > addDate(QUERY_DATE_S,1,0,0)){
    				alert("授權起訖日有誤!授權起日不得>今天，迄日不得超過授權起日+1年!");
    				return; 
    			}
    			return true;
    		},
    		doSetAfterSubmit : function(){
    			var filedata = window.importFrame.document.getElementById('filedata');
    			if(!filedata){
    				return;
    			}
    			var obj = filedata.innerHTML.evalJSON();		
    			
    			var Msg = obj.ErrMsg.msgDesc.replace('\\n','');
    			if(Msg){
    				alert(Msg);
    			}	
    			
    			if(CSRUtil.isSuccess(obj)){					
    				grid.load(obj.rtnList);									
    			}else{
    				grid.load([]);	
    			}							
    			auxiliary.closeCoverPage();
    		},
    		
    		<%--難字轉換--%>
    		unfamiliarTrans : function(){
    			var input = $("import_file");
    			$("import_file").remove();
    			parseEUDC('ap');
    			$("import").insert(input);
    		}
    	};
    	
    	var buttons = {
    		doQuery : function(){
    			var radio_select = $$('form input[name="QUERY_TYPE_radio"]');
    			var radio_INPUT_CRED_DEPT = radio_select[0].checked;
    			var radio_QUERY_TYPE = radio_select[1].checked;
    			
    			if(!radio_INPUT_CRED_DEPT && !radio_QUERY_TYPE){
    				alert("請選擇一種查詢方式");
    				return; 
    			}
    			if(radio_QUERY_TYPE && (!$F('QUERY_TYPE') || !$F('QUERY_TYPE_VALUE'))){
    				alert("請輸入查詢條件");
    				return; 
    			}
    			if(radio_QUERY_TYPE && $F('QUERY_TYPE') == "LOAN_ID" && $F('QUERY_TYPE_VALUE').length != 10){
    				alert("[貸款帳號]輸入長度不符");
    				return; 
    			}
    			if(radio_INPUT_CRED_DEPT && diffDay( $F('INPUT_DATE_S') , $F('INPUT_DATE_E') ) > 31){
    				alert("查詢日期不可為空，且區間不可超過1個月!");
    				return; 
    			}
    			if(!valid1.validate()){
    				return;
    			}
    			
    			var queryMap = {};
    			if(radio_INPUT_CRED_DEPT){
    				queryMap['INPUT_CRED_DEPT'] = $F('INPUT_CRED_DEPT');
    				queryMap['INPUT_DATE_S'] = $F('INPUT_DATE_S');
    				queryMap['INPUT_DATE_E'] = $F('INPUT_DATE_E');
    			}else if(radio_QUERY_TYPE){
    				var QUERY_TYPE = $F('QUERY_TYPE');
    				var QUERY_TYPE_VALUE = $F('QUERY_TYPE_VALUE');
    				
    				queryMap['QUERY_TYPE'] = QUERY_TYPE;
    				if('APPLY_ID' == QUERY_TYPE || 'LOAN_ID' == QUERY_TYPE){
    					queryMap['CASE_ID'] = QUERY_TYPE_VALUE;
    				}else if('QUERY_ID' == QUERY_TYPE){
    					queryMap['QUERY_ID'] = QUERY_TYPE_VALUE;
    				}
    			}
    			queryMap['STATUS'] = $F('STATUS');
    			
    			$('o_queryMap').setValue(Object.toJSON(queryMap));<%-- 原始查詢資料 --%>
    			$('BTN_query').setValue("Y");
    			ajaxRequest.post('query',{
    				reqMap : Object.toJSON(queryMap)
    			},
    			function(resp){
	    			var rtnList = resp.rtnList;
	    			grid.load(rtnList);
	    			if(radio_INPUT_CRED_DEPT || "QUERY_ID" == $F('QUERY_TYPE')){
	    				$('import_file').disable();
	    				$('BTN_GET0431').disable();
	    			}else if(radio_QUERY_TYPE && "APPLY_ID" == $F('QUERY_TYPE')){
	    				//若查詢方式為受理編號，則僅能點選影像選取
	    				$('import_file').disable();
	    				$('BTN_GET0431').enable();
	    			}else if(radio_QUERY_TYPE && "LOAN_ID" == $F('QUERY_TYPE')){
	    				//若查詢方式為受理編號，則僅能點選影像選取
	    				$('import_file').enable();
	    				$('BTN_GET0431').disable();
	    			}else{
	    				$('import_file').enable();
	    				$('BTN_GET0431').enable();
	    			}
	    			$('GET0431_FNAME').update('');
	    			$('FILE_FROM').setValue('');
	    		},
	    		function(resp){
	    			grid.load([]);
	    			$('GET0431_FNAME').update('');
	    			$('FILE_FROM').setValue('');
	    		});
    		},
    		doSubmit : function(){
    			if(!actions.check_BeforeSubmit()){
    				return;
    			}

    			var reqMap_json = Object.toJSON(actions.getSubmitMap());
    			
    			ajaxRequest.post('submitcheck',{
					reqMap : reqMap_json
				},
				function(resp){
    				var IsUnnormal = resp.IsUnnormal;
    				var confirm_boolean;
    				if(IsUnnormal){
    					if(!confirm("該授權ID尚有正在進行查調的案件，請先確認是否再次送出查詢。")){
    						return;
    					}else{
    						confirm_boolean = true;
    					}
    				}
    				if(!IsUnnormal || confirm_boolean){
    					$('reqMap_submit').setValue(reqMap_json);
						auxiliary.createCoverPage();
						
						$('form1').action="${dispatcher}/DSA2_0430/submit";
						$('form1').submit();
    				}
    			});
    		},
    		doConfirm : function(){
    			var checkList = grid.getCheckedRecord();
    			if(checkList.length == 0){
    				alert("請選取一筆資料");
    				return;
    			}
    			
    			ajaxRequest.post('confirm',{
    				reqList : Object.toJSON(checkList),
    				queryMap : $F('o_queryMap')
				},
				function(resp){
    				grid.load(resp.rtnList);
    			},
    			function(resp){
    				grid.load([]);
    			});
    		},
    		doDelete : function(){
    			var checkList = grid.getCheckedRecord();
    			if(checkList.length == 0){
    				alert("請選取一筆資料");
    				return;
    			}
    			
    			ajaxRequest.post('delete',{
    				reqList : Object.toJSON(checkList),
    				queryMap : $F('o_queryMap')
				},
				function(resp){
    				grid.load(resp.rtnList);
    			},
    			function(resp){
    				grid.load([]);
    			});
    			
    		},
    		doGet0431 : function(){
    			if("Y" != $F('BTN_query')){
    				alert("請先做查詢後，再點選此按鈕");
    				return;
    			}
    			popupWin.popup({
    				src: '${dispatcher}/DSA2_0431/prompt',scrolling : 'yes',
    				<%-- [20210819]移除程式碼: 移除closeBtn : false, --%>
    				width:'95%',<%-- [20210819]新增程式碼: 新增 width:'95%', --%>
    				parameters: { 
    					APPLY_ID : $F('QUERY_TYPE_VALUE'),			
    				}, 
    				cb : function(obj){
    					if(obj){
    						$('GET0431_FNAME').update('已選取: ' + obj[0].AV_FILE_NAME);
    						$('FILE_FROM').setValue('2');
    						$('AV_FILE_NAME').setValue(obj[0].AV_FILE_NAME);
    					}
    				}
    			});
    		},
    		doClean0431 : function(){
    			$('GET0431_FNAME').update('');
    			$('FILE_FROM').setValue('');
    		},
    		dolinkTOJCIC : function(record){
    			
    			//調整查詢聯徵歷史資料來源
				var toDay = addDate(getY2KToday(),0,0,-7);
				var qDate = toY2K(record.QDATE);
				var chkMap = {};  
				chkMap.TXID = record.TXID;
				chkMap.MSGID = record.MSGID;
				chkMap.QDATE = record.QDATE;
				chkMap.QUERYKEY1 = record.QUERYKEY1;
				chkMap.QUERYKEY2 = record.QUERYKEY2;
				chkMap.ISPRINT = record.ISPRINT;
				chkMap.CRED_DEPT = record.CRED_DEPT;
				//[申請書:24120444624]建立聯徵查詢存取軌跡紀錄:多傳入受理編號or貸款帳號
				chkMap.CASE_ID = record.CASE_ID;
				chkMap.NAME = record.QUERY_NAME;
		
				var url = "<%=dispatcher%>/DSA2_2200/prompt?chkList="+Object.toJSON([chkMap])+"&LINK_FROM=DSA20410";
				if(diffDay(qDate, toDay) >= 0){
					url = "<%=dispatcher%>/DSA2_0410/queryDetail?chkList="+Object.toJSON([chkMap])+"&LINK_FROM=DSA20410";
				}
				
				window.open(url, "DSA2_0410", "top=50, left=50, toolbar=yes, resizable=yes, location=0, scrollbars=1, status=0, titlebar=0, width=800, height=600");
    		},
    		doPreview : function(rec){
    			ajaxRequest.post('preview',{
    				reqMap : rec,
				},
				function(resp){
    				var dataMap = {
    					'encryptTempFileFullPath': resp.filePath
    				};
    				RPTUtil.executeSecurityPrintHandler(dataMap);
    			});
    		},
    		doSecPrint : function(rec){
    			//1.
    			if("APPLY_ID" != $F('QUERY_TYPE')){
    				alert("授權書二次套印前查詢方式須選擇[受理編號]");
					return;
    			}
    			//2.
    			var ID_VALUE = $F('QUERY_TYPE_VALUE');
    			if("APPLY_ID" == $F('QUERY_TYPE')){
    				if(ID_VALUE.length!=11){
    					alert("[受理編號]輸入長度不符");
    					return;
    				}
    			}
    			//3.
    			ajaxRequest.post('SecPrint',{
    				APPLY_ID : ID_VALUE,
    				queryMap : $F('o_queryMap')
				},
				function(resp){
    				grid.load(resp.rtnList);
    			},
    			function(resp){
    				grid.load([]);
    			});
    		}
    	}
    	
    	function buttonAuth(){
    		var authButtons = {
    				<%--B0031:"BTN_submit", 送出查詢--%>
		    		B0047:"BTN_confirm" <%--作業覆核--%>
    		        <%--B0005:"BTN_delete", <%--刪除--%>
    		        <%--B0064:"BTN_GET0431" <%--影像選取--%>
    		        ,B0260:"BTN_SEC_PRINT" <%--授權書二次套印--%>
    		};
    		<dz:grantButtons FUNC_ID="DSA20430"/>
    	}
    	
        return {
            initApp: function(){
            	<cathay:LocaleDisplay dateFields="INPUT_DATE_S INPUT_DATE_E QUERY_DATE_S QUERY_DATE_E" sysCode= 'DS' var='localeDisplay' />            	
                PageUI.createPageWithAllBodySubElement(
					'DSA20430',
					'核貸作業',
					'公務機關查調作業'
				);
				
                var groupKey_All = ["QUERY_ID","CASE_ID","SEQ_NO"];
				
				grid = new TableUI({
					table : $('grid'),
					whenDataNull : '',
					overDiv : true,
					pageSize: 10,
					allSortable: true,
					<%-- [20240729] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { actions.unfamiliarTrans(); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { actions.unfamiliarTrans(); }
					},
					autoCheckBox : {
						isSelectAll :true,
						<%--[20211007]問題單號：20211006162756 若該筆資料showCheckBox = N，則該筆checkbox disable--%>
						disableRule: function(record, sn){
							if(record.showCheckBox == 'N') {
								return true;
							}
						}
					},
					column : [
						{header : "作業日", key:"INPUT_TIME", groupKey:groupKey_All},
						<%--[2022.02.21]優化by詩婷 新增欄位(作業單位/授權起日/授權迄日)--%>
						{header : "作業單位", key:"INPUT_CRED_DEPT", groupKey:groupKey_All},
						{header : "作業人員", key:"INPUT_NM", groupKey:groupKey_All, attrs:{style:"font-family:'EUDC'"}}, <%-- [20240729]難字調整 --%>
						{header : "授權人ID", key:"QUERY_ID", groupKey:groupKey_All},
						{header : "姓名", key:"QUERY_NAME", groupKey:groupKey_All, attrs:{style:"font-family:'EUDC'"}}, <%-- [20240729]難字調整 --%>
						{header : "受理編號", key:"CASE_ID", groupKey:groupKey_All,
							<%--[2022.02.21]優化by詩婷 取消超連結--%>
						<%--render:function(rec,val){
								if(val){
									var link = new Element( 'a' , { href : "javascript:void(0);" } ).update(val);
									var reqMap = {};
									reqMap['QUERY_DATE_S'] = rec.QUERY_DATE_S;
									reqMap['QUERY_DATE_E'] = rec.QUERY_DATE_E;
									var QUERY_ITEM = rec.QUERY_ITEM;
									if("T50" == QUERY_ITEM){
										reqMap['QUERY_T50'] = "Y";
									}
									if("T51" == QUERY_ITEM){
										reqMap['QUERY_T51'] = "Y";
									}
									if("T52" == QUERY_ITEM){
										reqMap['QUERY_T52'] = "Y";
									}
									
									link.observe('click', function(){
										actions.set_SectionB(reqMap);
									});
									return link;
	                            }
								return val;
							}--%>
						},
						{header : "授權起日", key:"QUERY_DATE_S", groupKey:groupKey_All},
						{header : "授權迄日", key:"QUERY_DATE_E", groupKey:groupKey_All},
						{header : "授權項目", key:'QUERY_ITEM',
							render:function(rec,val){
								var STATUS = rec.STATUS;
								var QUERY_ITEM = rec.QUERY_ITEM;
								var QUERY_ITEM_zh = rec.QUERY_ITEM_zh;
								
								if("0" == STATUS && rec.HYPER_AUTH == true){
									//聯徵資料單元TAM5XX
									var link = new Element( 'a' , { href : "javascript:void(0);" } ).update(QUERY_ITEM_zh);
									link.observe('click', function(){
										buttons.dolinkTOJCIC(rec);
									});
									return link;
								}
								
								return QUERY_ITEM_zh;
							}
						},
						{header : "處理狀態", key:"STATUS_MEMO",
							render:function(rec,val){
								var split_val;
								if(val.length > 10){
									split_val = val.substring(0,10) + '...';
								}else{
									split_val = val;
								}
								
								var ele = new Element( 'span' , { title : val, all_val : val, style : "word-break: nowrap"} ).update(split_val);
								ele.observe('click', function(){
									if(ele.innerHTML.length <= 13){
										ele.update(val);
									}else{
										ele.update(split_val);
									}
								});
								return ele;
							}
						},
						{header : "影像預覽", key:"preview", groupKey:groupKey_All,
							render:function(rec,val){
								var img = new Element("img" , { src : '${imageBase}/CM/menu/item3.gif' , border : '0'} );
								
								var link = new Element( 'a' , { href : "javascript:void(0);", dataInfo : Object.toJSON(rec) } ).update(img);
								link.observe('click',function(){
									buttons.doPreview(link.getAttribute('datainfo'));
								});
								return link;
							}	
						},
						{header : "方式", key:"APPLY_FROM", groupKey:groupKey_All,
							render:function(rec,val){
								if("DSA20400" == val){
									return "系統帶入";
								}
								return "自行輸入";
							}
						},
						{header : "覆核人員", key:"CFM_NM", groupKey:groupKey_All, attrs:{style:"font-family:'EUDC'"}, <%-- [20240729]難字調整 --%>
							render:function(rec,val){
								var CFM_TIME = rec.CFM_TIME;
								if(!CFM_TIME){
									return val;
								}
								return val + "<br/>" + CFM_TIME;
							}	
						}
					]
				});
				
				$('BTN_query').observe('click', buttons.doQuery);
				$('BTN_submit').observe('click', buttons.doSubmit);
				$('BTN_confirm').observe('click', buttons.doConfirm);
				$('BTN_GET0431').observe('click', buttons.doGet0431);
				$('BTN_CLEAN0431').observe('click', buttons.doClean0431);
				$('BTN_delete').observe('click', buttons.doDelete);
				$('QUERY_TYPE_VALUE').observe('change', function(){
					$('QUERY_TYPE_VALUE').setValue($F('QUERY_TYPE_VALUE').toUpperCase());
				});
				<%--[20210906]【承辦科別】或【查詢方式】下拉式選單若有選取時，前方RADIO同時checked。--%>
				$('INPUT_CRED_DEPT').observe('change', function(){
					$$('[name="QUERY_TYPE_radio"]')[0].checked = true; 
				});
				$('QUERY_TYPE').observe('change', function(){
					$$('[name="QUERY_TYPE_radio"]')[1].checked = true; 
					<%--[20210906]
				  (1) 選擇[授權人ID]：[選取檔案]與[影像選取]均disable。
			      (2) 選擇[受理編號]：[選取檔案] disable。
			      (3) 選擇[貸款帳號]：[影像選取]disable。
			      --%>
			      $('import_file').disabled = false;
		    	  $('BTN_GET0431').disabled = false;
			      if(this.value==='QUERY_ID'){
			    	  $('import_file').disabled = true;
			    	  $('BTN_GET0431').disabled = true;
			      }else if(this.value==='APPLY_ID'){
			    	  $('import_file').disabled = true;
			      }else if(this.value==='LOAN_ID'){
			    	  $('BTN_GET0431').disabled = true;
			      }
				});
				$('importFrame').observe('load', actions.doSetAfterSubmit);
				$('BTN_SEC_PRINT').observe('click', buttons.doSecPrint);
				
				initValidation();
				buttonAuth();
				PageUI.resize();
				displayMessage();
            }
        };
    }

</script>
</head>
<body>
	<form name="form1" id="form1" method="post" target="importFrame" enctype="multipart/form-data" >
	<iframe id="importFrame" name="importFrame" width="0" height="0"></iframe><%-- 匯入檔案時，模擬Ajax的效果 --%>	
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<input type="hidden" id="reqMap_submit" name="reqMap_submit" />
			<input type="hidden" id="o_queryMap" name="o_queryMap" />
			<%-- A區 --%>
			<tr>
				<th colspan="5" align="left">查詢方式</th>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >
					<input type="radio" name="QUERY_TYPE_radio" value="1" checked/>承辦科別
				</td>
				<td class="tbYellow2" width="auto" >
					<select id="INPUT_CRED_DEPT" name="INPUT_CRED_DEPT" title="承辦科別" class="textBox2">
						<option value="">全部</option>
						<%--[20210906]【承辦科別】預帶user.getDivNo()--%>
						<c:forEach var="map" items="${INPUT_CRED_DEPT_List}">
				 			<option value="${map.key}" ${(map.key eq DIV_NO) ? 'selected' :'' }>${map.value}</option>
						</c:forEach>
					</select>
				</td>
				<td class="tbYellow" width="15%" >作業日期</td>
				<td class="tbYellow2" width="auto" >
					<input id="INPUT_DATE_S" name="INPUT_DATE_S" title="查詢起日" datatype="ROCDate" type="text" class="textBox2 chkDiffDay1 chkDiffDay2" value="${ROCTODAY}" >~
					<input id="INPUT_DATE_E" name="INPUT_DATE_E" title="查詢迄日" datatype="ROCDate" type="text" class="textBox2" value="${ROCTODAY}" />
					<font color="gray">*查詢區間限1個月</font>
				</td>
				<td class="tbYellow2" align="center" rowspan="2" width="5%" >
					<button type="button" id="BTN_query" class="button">查詢</button>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" >
					<input type="radio" name="QUERY_TYPE_radio" value="2" />查詢方式
				</td>
				<td class="tbYellow2" >
					<select id="QUERY_TYPE" name="QUERY_TYPE" title="查詢方式" class="textBox2">
						<option value="">請選擇</option>
						<c:forEach var="map" items="${QUERY_TYPE_List}">
				 			<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
					<input id="QUERY_TYPE_VALUE" name="QUERY_TYPE_VALUE" type="text" size="20" class="textBox2 chkID chkAPPLY_ID" />
					<button type="button" id="BTN_SEC_PRINT" class="button">授權書二次套印</button>
				</td>
				<td class="tbYellow" width="15%" >處理狀態</td>
				<td class="tbYellow2" width="auto" >
					<select id="STATUS" name="STATUS" title="處理狀態" class="textBox2">
						<option value="">全部</option>
						<c:forEach var="map" items="${STATUS_LIST}">
				 			<option value="${map.key}">${map.value}</option>
						</c:forEach>
					</select>
				</td>
			</tr>	
			<%-- B區 --%>
			<tr>
				<th colspan="4" align="left">上傳作業  <font color="red">進行上傳作業前，查詢方式需先以受理編號或貸款帳號查詢。</font></th>
			</tr>
			<tr>
				<input type="hidden" id="IS_FILE" name="IS_FILE"/>
				<input type="hidden" id="FILE_FROM" name="FILE_FROM"/>
				<input type="hidden" id="AV_FILE_NAME" name="AV_FILE_NAME"/>
				<td class="tbYellow" width="15%" >選取檔案</td>
				<td class="tbYellow2" width="auto">
					<span id="import">
						<input id="import_file" name="import_file" type="file" size="50" accept=".jpeg">
					</span>
					<button type="button" class="button" id="BTN_GET0431" >影像選取</button>
					<span id="GET0431_FNAME"></span>
					<font color="red">選擇檔案上傳者，限.jpeg圖檔，300dpi全彩或灰階影像。</font>
				</td>
				<td class="tbYellow2" colspan="3" width="15%">
					<button type="button" class="button" id="BTN_CLEAN0431">清除影像選取</button>
				</td>
			</tr>		
			<tr>
				<td class="tbYellow" width="15%" >機構代號</td>
				<td class="tbYellow2" width="auto">
					<input id="INPUT_CRED_DEPT_upload" name="INPUT_CRED_DEPT_upload" type="text" class="textBox2" size="20" disabled="disabled" value="${INPUT_CRED_DEPT}" />
					<font color="gray">*確認與授權書機構代號是否一致</font>
				</td>
				<td class="tbYellow" width="15%" >授權起迄日</td>
				<td class="tbYellow2" width="auto" colspan="2">
					<input id="QUERY_DATE_S" name="QUERY_DATE_S" title="授權起日" datatype="ROCDate" type="text" class="textBox2" value="" />~
					<input id="QUERY_DATE_E" name="QUERY_DATE_E" title="授權迄日" datatype="ROCDate" type="text" class="textBox2" value="" />
					<font color="gray">*授權起日為簽署日</font>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="15%" >授權項目</td>
				<td class="tbYellow2" width="auto" colspan="4">
					<input type="checkbox" name="QUERY_T50" id="QUERY_T50" value="T50" />T50年度所得
					<input type="checkbox" name="QUERY_T51" id="QUERY_T51" value="T51" />T51財產清單
					<input type="checkbox" name="QUERY_T52" id="QUERY_T52" value="T52" />T52勞保資料
				</td>
			</tr>	
			<tr>
				<td class="tbYellow2" align="center" colspan="5">
					<button type="button" id="BTN_submit" class="button">送出查詢</button>
					<button type="button" id="BTN_confirm" class="button">作業覆核</button>
					<button type="button" id="BTN_delete" class="button">刪除</button>
				</td>
			</tr>
		</table>
	</form>
	<table id="grid" class='grid'></table>
	<table width="100%" border=0 cellSpacing=1 cellPadding=0 >
			<tr>
				<td class="tbGreen" width="10%">
		        	※財稅資料係為課稅目的蒐集，僅供金融徵信案件之參考，若有資料內容疑問時，應向資料主管機關洽詢。 <br>
		        	※操作說明 <br>
		        	1.刪除鈕供處理狀態為「待覆核」時使用。 <br>
		        	2.單位代號：總公司4540007、授信審查一科454GV04、授信審查二科454GV06、放款資產管理科454LN02。
		        </td>
			</tr>
	</table>
</body>
</html>
