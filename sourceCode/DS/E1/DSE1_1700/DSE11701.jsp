<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>

<!--
程式：DSE11701.jsp
作者：張智翔
功能：繼承管理明細。
完成：2013/5/21

[20230628]修改件
問題1.新增繼承人資料，通訊地址並不會寫入DTDSE173  
問題2.修改時日期欄位會修改失敗

[20240215]難字調整
-->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp" %>


<!--匯入外部Javascript 與 css-->
<title></title>
<link href='<%=cssBase%>/cm.css' rel='stylesheet' type='text/css'>
<style type="text/css">
	.gridSpan input{
		margin-left:5px;
	}
	.gridSpan select{
		margin-left:5px;
	}
</style>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/prototype.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ajax/CSRUtil.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/utility.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>

<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 		<%-- 日曆用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script> 		<%-- 日曆用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>	<%-- 檢核用 --%>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/RPTUtil.js"></script>		<%-- 匯出檔案用 --%>
<script type="text/JavaScript" src="<%=htmlBase%>/DS/js/DSZ01000.js"></script>	      <%-- 地址用 --%>
<script type='text/javaScript' src='${htmlBase}/CM/js/ui/LocaleDisplay.js'></script>
<%--[20240215]難字css  --%>
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

// 產生畫面物件
var DSE11701 = new DSE11701();

// 透過 prototype 的 Event 物件監聽 onload 事件，觸發時進行頁面物件的 initApp
Event.observe(window, 'load', DSE11701.initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11701(){
    //紀錄死亡日期檢核狀態
	var checkday_record=true;
	
	var without_ancestorMap = '${without_ancestorMap}';
	
	var RELATION_Map;
	
	var checkIDList = [];

	<%-- 順位下拉選單 --%>
	var PRIORITY_Map = {};
		<c:forEach items="${PRIORITY_LIST}" var="row">PRIORITY_Map['${row.key}'] = '${row.value}';						
		</c:forEach>
		
	<%-- 順位下拉選單 --%>
	var PRIORITY_Map = {};
		<c:forEach items="${PRIORITY_LIST}" var="row">PRIORITY_Map['${row.key}'] = '${row.value}';						
		</c:forEach>

	<%-- 繼承情況下拉選單 --%>
	var HEIR_CODE_Map = {};
		<c:forEach items="${HEIR_CODE_LIST}" var="row">HEIR_CODE_Map['${row.key}'] = '${row.value}';						
		</c:forEach>

	<%-- 法阮下拉選單 --%>
	var COURT_Map = {};
	    
		<c:forEach items="${COURT_LIST}" var="entry">
		
		COURT_Map['${entry.key}'] = '${entry.value}';						
		</c:forEach>

	<%-- 鄉鎮市區的 cache，key 值為縣市的 code --%>
	var TOWN_NAMECache = {};

	//Table UI
	var grid;
    var grid2;
	var SELECT_DOM;

	//檢核
	var valid1;		
	
	var ADDR;

	//畫面檢核
	function initValidation(){
		//查詢用檢核
		Validation.addAllThese([
			[ 'checkCASE_NO',  '為拋棄繼承、限定繼承，則案號必須輸入',
				function(v , node){					
					var tr = node.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var HEIR_CODE = dataObj.HEIR_CODE;
					if((HEIR_CODE == '2' || HEIR_CODE =='3') && !v){
						return false;
					}
					return true;
				}
			],
			[ 'checkDEADTHDAY',  '繼承情形為代位繼承、再轉繼承、繼承前死亡，則死亡日期必須輸入',
				function(v , node){
					var tr = node.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var HEIR_CODE = dataObj.HEIR_CODE;
					if((HEIR_CODE == '4' || HEIR_CODE =='5' || HEIR_CODE =='6') && !v){
						return false;
					}
					return true;						
				}
			],
			[ 'checkID',  '身份證字號格式錯誤',
				function(v){
					return Validation.get('IsEmpty').test(v) || validation.checkROCID( v );
				}
			],
			['validate-ROCDate-Before-Bir', '請輸入正確的民國日期格式', function(v) {
	            if( !Validation.get('IsEmpty').test(v) ){
	                var k = $('BIRTHDAY_2').value ;
	                return isROCdate(k,false,true);
	            }
	            return true;
       		 }],
        
        	['validate-ROCDate-Before-Dead', '請輸入正確的民國日期格式', function(v) {
	            if( !Validation.get('IsEmpty').test(v) ){
	            	var k = $('DEADTHDAY').value ;
	                return isROCdate(k,false,true);
	            }
	            return true;
        	}],
			['check-validate-ROCDate-interval', '繼承情形為繼承前死亡，則死亡日期必須小於被繼承人死亡日期', function(v,node) {
				var tr = node.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					var HEIR_CODE = dataObj.HEIR_CODE;
					if(HEIR_CODE == '6'){
					    str_dt=dataObj.DEADTHDAY;
						end_dt=$('DEADTHDAY').value;
						if( !Validation.get('IsEmpty').test(str_dt) && !Validation.get('IsEmpty').test(end_dt) ){	//確認有輸入		
							
							return diffDayROC(str_dt, end_dt ) >= 0;
						}

						return true;
					}
				return true;
			}],
			[ 'customize_returnFalse', '不可為空',
				function(obj){
					return false;
				}
			],
			[ 'checkCode', '郵遞區號不可為空',
				function(obj){
					if(ADDR.getINPUT_ZIPCODE()){
						return true;
					}
					return false;
				}
			],
			[ 'requiredID', '不可為空',
				function(v , node){
					var tr = node.up('tr');
					var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
					if( !dataObj.DEADTHDAY && Validation.get('IsEmpty').test(v) ){
						return false;
					}
					return true;						
				}
			]
			
		]);
			
		valid1 = new Validation("form", { focusOnError:true, immediate:false , mode : 'validator'});

		valid2 = new Validation("form1", { focusOnError:true, immediate:false , mode : 'validator'});					
			
	}
	
	//按扭權限
	function buttonAuth(){
		var authButtons = {
			  B0003 : "btn_insert"
			, B0004 : "btn_update_under"
			, B0005 : [ 'btn_deleteA', "btn_delete" ]
			, B0070 : "btn_confirm"
			, B0071 : "btn_cancelconfirm"
			, B0204 : "btn_close_confirm"
			, B0106 : "btn_close_cancelconfirm"
		};

		<dz:grantButtons FUNC_ID="DSE11701"/>

		for( var i = 0 ; i < legal.length ; i++){
			if(legal[i] == 'B0004'){
				$('btn_updateA').enable();
			}
		}
	}

	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		new Ajax.Request( "<%=dispatcher%>/DSE1_1701/" + actionName,
			{  
			parameters: params, 
			onSuccess:function(response){
				var resp = response.responseJSON
				if(CSRUtil.isSuccess(resp)){	
					if(successFunction){
						successFunction(resp);
					}
				}else{
					if(errorFunction){
						errorFunction(resp);
					}
				}
			}			
		});
	}

	//將tableUI中的所有輸入欄位
	function ClearFieldsDefine(){
		$$('#grid input[type !="checkbox"] , select').each(
			function(elem){
				elem.setAttribute( 'className' , 'textBox2');
			
			}			
		)	
	}

	//對勾選的欄位做檢核
	function checkAllFileds(){

		//抓出有被選的
		$$('#grid tbody input:checked[type="checkbox"]').each(function(elem){
					var tr = elem.up('tr');
					var sn = tr.getAttribute('sn')
					var HEIR_CODE;
					//下拉選單檢核
					$w('PRIORITY RELATION HEIR_CODE').each(
						function(id){
							var dom;
							if(grid.isNew){
								dom = $$('#grid tr[sn='+sn+'] td[name ='+id+'] select')[0];
							}else{
								dom = tr.select('td[name ='+id+']')[0].select('select')[0];//(tbody.select('td[name ='+id+']')[0].select('select')[0]) || (tr.select('td[name ='+id+'] > select')[0]);
							}
							dom.setAttribute ('className' , 'required');	
							if(id == 'HEIR_CODE'){
								HEIR_CODE = dom.value;
							}
						}
					
					);
					//input欄位檢核
					$w('HEIR_NAME HEIR_ID').each(
						function(id){
							var dom;
							if(grid.isNew){
								dom = $$('#grid tr[sn='+sn+'] td[name ='+id+'] input')[0];
							}else{
								dom = tr.select('td[name ='+id+']')[0].select('input')[0];//(tbody.select('td[name ='+id+']')[0].select('input')[0])
							}
							if(id == 'HEIR_ID'){
								dom.setAttribute ('className' , 'textBox2 checkID requiredID');
								dom.setAttribute ('length' , 20);
							}else if(id == 'HEIR_NAME'){
								dom.setAttribute ('className' , 'textBox2 required');
							}
						}				
					);

					//因為被切兩個tr 一筆資料,所以要抓下個tr中的DEADTHDAY 與CASE_NO , BIRTHDAY
					var nextTr = $(tr.nextSibling);					

					$w('BIRTHDAY CASE_NO DEADTHDAY').each(
						function(id){
							var dom;
							if(grid.isNew){
								dom = $$('#grid tr[sn='+sn+'] td[name ='+id+'] input')[0];
							}else{
								dom = nextTr.select('td[name ='+id+']')[0].select('input')[0];//tbody.select('td[name ='+id+']')[0].select('input')[0]
							}
							
							if(id == 'BIRTHDAY'){
	                            dom.setAttribute ('className' , 'textBox2 validate-ROCDate-Before-Bir required');    
	                        }else if(id == 'CASE_NO'){
	                            dom.setAttribute ('className' , 'textBox2 checkCASE_NO');    
	                        }else if(id == 'DEADTHDAY'){
	                            dom.setAttribute ('className' , 'textBox2 validate-ROCDate-Before-Dead checkDEADTHDAY check-validate-ROCDate-interval');
	                       }
						}				
					);	
		});

	}

	//按鈕功能
	var buttons = {
	
		//查詢
		doQuery : function(){
			//發送ajax
			ajaxPost( 'query' , { ANCESTOR_ID : '${ANCESTOR_ID}' , 	ANCESTOR_NAME : '${ANCESTOR_NAME}' , BIRTHDAY_NM : '${BIRTHDAY_NM}' },
				function(resp){
					actions.showData(resp.ancestorMap);
					grid2.load(resp.closeList || []);
					grid.load(resp.heirList);
				},
				function(resp){
					grid2.load([]);				
					grid.load([]);
				}
			);
		},
		
		//修改
		doUpdate : function(){
			
			valid1.reset();	
			valid1.clear();
			
			ADDR.checkData(valid1,{'CITY_NAME':'CITY_NAME','TOWN_NAME':'TOWN_NAME'},'');
			valid1.define( "required" , { id: "DEADTHDAY"  } );	
			valid1.define( "checkCode" , { id: "ADDR_INPUT_ADDR"  } );	
			if(!valid1.validate()){
				return;
			}		
			//A區資料存成reqMap
			var reqMap = {
				ANCESTOR_ID : $('ANCESTOR_ID').innerHTML,
				DEADTHDAY : $F('DEADTHDAY'),
				BIRTHDAY : $F('BIRTHDAY_2'),
				TOWN_CODE : ADDR.getINPUT_ZIPCODE(),
				ADDR : ADDR.getINPUT_ADDR()
			};
			
			//發送ajax
			ajaxPost( 'update' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}',	
					reqMap : Object.toJSON(reqMap) 
				},
				function(resp){	
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);					
					grid.load(heirList);
				}
			);	
		
		},
		// 刪除(A 區)
		doDeleteA : function() {
			if (!confirm('相關繼承人資料將同步刪除，請確認是否刪除被繼承人資料？')) { return; }

			var reqMap = {
				  'ANCESTOR_ID' : $('ANCESTOR_ID').innerHTML
				, 'DEADTHDAY'   : $F('DEADTHDAY')
				, 'BIRTHDAY'    : $F('BIRTHDAY_2')
				, 'TOWN_CODE'   : ADDR.getINPUT_ZIPCODE()
				, 'ADDR'        : ADDR.getINPUT_ADDR()
			};

			ajaxPost(
				  'deleteA'
				, { 'reqMap' : Object.toJSON(reqMap) }
				, function(resp) { CSRUtil.linkBack(); }
			);
		},
		//新增
		doInsert : function(event){		
			var insertRecord = actions.getCheckedRecord({isGetExtInput:true});
			if(insertRecord.length == 0){
				alert('至少需選取一筆資料!');
				return;
			}

			//消去檢核			
			ClearFieldsDefine();
			//執行檢核
			checkAllFileds();

			if(!valid2.validate()){					
				return;
			}

			//發送ajax
			ajaxPost( 'insert' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}',	
					dataList : Object.toJSON(insertRecord)
				},
				function(resp){	
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);					
					grid.load(heirList);								
				}				
			);	
		},
		
		//修改 下層
		doUnderUpadte : function(event){		
			var insertRecord = actions.getCheckedRecord({isGetExtInput:true});
			if(insertRecord.length == 0){
				alert('至少需選取一筆資料!');
				return;
			}

			//消去檢核			
			ClearFieldsDefine();
			//執行檢核
			checkAllFileds();
			
			
			if(!valid2.validate()){							
				return;
			}

			//發送ajax
			ajaxPost( 'update_under' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}',	
					dataList : Object.toJSON(insertRecord) 

				},
				function(resp){	
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);					
					grid.load(heirList);								
				}				
			);	
		},
		
		//刪除
		doDelete : function(){
			var insertRecord = actions.getCheckedRecord({colNames:['ANCESTOR_ID', 'SEQ_NO']});
			if(insertRecord.length == 0){
				alert('至少需選取一筆資料!');
				return;
			}
			if(!confirm('該筆紀錄將會全部刪除，請確認是否繼續?')){
				return;			
			}
		
			//發送ajax
			ajaxPost( 'delete' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}',	
					dataList : Object.toJSON(insertRecord)
				},
				function(resp){	
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);					
					grid.load(heirList);								
				}				
			);	
		},
		//覆核
		doConfirm : function(){
			var insertRecord = actions.getCheckedRecord({colNames:['ANCESTOR_ID', 'SEQ_NO']});
			if(insertRecord.length == 0){
				alert('至少需選取一筆資料!');
				return;
			}

			//發送ajax
			ajaxPost( 'confirm' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}',	
					dataList : Object.toJSON(insertRecord) 
				},
				function(resp){
					actions.showData(resp.ancestorMap);					
					grid.load(resp.heirList);								
				}				
			);	
		},
		//取消覆核
		doCancelConfirm : function(){
			var insertRecord = actions.getCheckedRecord({colNames:['ANCESTOR_ID', 'SEQ_NO']});
			if(insertRecord.length == 0){
				alert('至少需選取一筆資料!');
				return;
			}	
		
			//發送ajax
			ajaxPost( 'cancelconfirm' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}',	
					dataList : Object.toJSON(insertRecord) 
				},
				function(resp){	
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);					
					grid.load(heirList);								
				}				
			);	
		},
		
		//新增繼承人
		doAddPerson : function(){
			if(without_ancestorMap =='Y'){
				alert('請先修正被繼承人資料!');
				return;
			}
			//發送ajax
			ajaxPost( 'newaddperson' , { 
					ANCESTOR_ID : '${ANCESTOR_ID}' 					
				},
				function(resp){	
					var courtMap = resp.courtMap;
					var LST_PROC_NM = resp.LST_PROC_NM;
					var LST_PROC_DATE = resp.LST_PROC_DATE;

					var tempMap = {
						ANCESTOR_ID : '${ANCESTOR_ID}', 						
						PRIORITY : '1' , 
						HEIR_CODE : '1',
						HEIR_NAME : '',
						HEIR_ID : '',
						BIRTHDAY : '',
						DEADTHDAY : '',
						HEIR_ID : '',
						STATUS : 10,
						COURT_NAME : courtMap.COURT_NAME ||'',
						COURT_CODE : courtMap.COURT_CODE ||'',
						LST_PROC_NM : LST_PROC_NM || '',
						LST_PROC_DATE : LST_PROC_DATE || ''					
					}

					var heirList = actions.getHeirRecords();
						heirList.push(tempMap);
					grid.load(heirList);
				}				
			);	
		
		},
		
		//製表
		doPrint : function(){		
			
			var	url = '<%=dispatcher%>/DSE1_1702/prompt'		
			params = {
				ANCESTOR_ID : '${ANCESTOR_ID}' 
			};
		
			RPTUtil.executePrintByLink( url, params);	
		
		},
		
		//上一頁
		doBack : function(){
			CSRUtil.linkBack();		
		},
		//結案新增
		doCloseInsert : function(){
           //將畫面上的欄位存成reqMap
		   if ($('CLOSED_REASON').value == ""){
				alert("請輸入結案原因")
				return;
		   }
		   if ($('CLOSED_REASON').value == "6" && $('CLOSED_MEMO').value == "" ){
				alert("結案原因為其他，請於後方輸入原因")
				return;
		   }
		   
		    var reqMap = {};
			$w('CLOSED_REASON CLOSED_MEMO').each(
				function(id){
					reqMap[id] = $(id).value;
				}
			);	
			reqMap['ANCESTOR_ID'] = $('ANCESTOR_ID').innerHTML;
           ajaxPost('closeInsert',{reqMap: Object.toJSON(reqMap),					
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}'	},
				function(resp){
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);		
					grid2.load(resp.closeList || []);					
					grid.load(heirList);					
				}
			);
		},
		//結案刪除
		doCloseDelete : function(){
           //取得勾選資料 且檢核       
           var reqList = grid2.getCheckedRecord(['ANCESTOR_ID', 'SEQ_NO']);
           if(reqList.length == 0){
			   alert('請至少選取一筆欲覆核資料');
			   return;
	       }
           ajaxPost('closeDelete',{reqMap: Object.toJSON(reqList[0]),					
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}'},
				function(resp){
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);		
					grid2.load(resp.closeList || []);					
					grid.load(heirList);					
				}
			);
		},
		//結案覆核
		doCloseConfirm : function(){
           //取得勾選資料 且檢核       
           var reqList = grid2.getCheckedRecord(['ANCESTOR_ID', 'SEQ_NO']);
           if(reqList.length == 0){
			   alert('請至少選取一筆欲覆核資料');
			   return;
	       }
           ajaxPost('closeConfirm',{reqMap: Object.toJSON(reqList[0]),					
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}'},
				function(resp){
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);		
					grid2.load(resp.closeList || []);					
					grid.load(heirList);					
				}
			);
		},
		//結案取消覆核
		doCloseCancelConfirm : function(){
           //取得勾選資料 且檢核       
           var reqList = grid2.getCheckedRecord(['ANCESTOR_ID', 'SEQ_NO']);
           if(reqList.length == 0){
			   alert('請至少選取一筆欲覆核資料');
			   return;
	       }
           ajaxPost('closeCancelConfirm',{reqMap: Object.toJSON(reqList[0]),					
					ANCESTOR_ID : '${ANCESTOR_ID}' , 
					ANCESTOR_NAME : '${ANCESTOR_NAME}' , 
					BIRTHDAY_NM : '${BIRTHDAY_NM}'},
				function(resp){
					var heirList = resp.heirList;
					actions.showData(resp.ancestorMap);		
					grid2.load(resp.closeList || []);					
					grid.load(heirList);					
				}
			);
		}
		
	}

	//各種action
	var actions = {				
		showData : function(ancestorMap){
			
			if(ancestorMap){	
				$$('#tableA input[type = text]', '#tableA select' , '#tableA span').each(
					function (elem){
						var tagName = elem.tagName;
						if(elem.id == 'BIRTHDAY_2' ){
							elem.value = Date.toInputROC(ancestorMap['BIRTHDAY']||'');
						}else if(tagName == 'INPUT' || tagName == 'SELECT'){
							elem.value = ancestorMap[elem.id] || '';					
						}else{
							elem.innerHTML = ancestorMap[elem.id] || '';
						}
					}		
				
				)		
				ADDR.setINPUT_ZIPCODE(ancestorMap.TOWN_CODE);	
				ADDR.setINPUT_ADDR(ancestorMap.ADDR);	
			}
		
		},
		
		//取的關係下拉選單
		doChangeRelation : function(PRIORITY){
			SELECT_DOM = new Element('SELECT' , { fieldName : '關係' });
			SELECT_DOM.add(new Option( '請選擇', ''));	
			if(PRIORITY){	
				Ajax.Responders.unregister(CSRUtil.defaultAjaxHandler);
				new Ajax.Request(
				"<%=dispatcher%>/DSE1_1701/getRelation",
					{  parameters : { PRIORITY :  PRIORITY}
					,asynchronous: false 
					,onSuccess: function(response) {
						var resp = response.responseJSON;
						if(CSRUtil.isSuccess(resp)){
							Ajax.Responders.register(CSRUtil.defaultAjaxHandler);
							RELATION_Map =  resp.RELATION_Map;	

							for(key in RELATION_Map){					
								SELECT_DOM.add(new Option( RELATION_Map[key] , key));
							}								

							SELECT_DOM.observe('change' , 
								function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.RELATION = event.target.value;
								}
							);
							
						}else{
							Ajax.Responders.register(CSRUtil.defaultAjaxHandler);						
						}
					}
				});				
			}
		},
		getCheckedRecord: function(opt){
			var insertRecord = grid.getCheckedRecord(opt['colNames']);
			if(opt['isGetExtInput']){
				var index=0;
				$('grid').select('tbody input[type=checkbox]').each(function(ele){
					if(!ele.checked){
						return;
					}
					var extInputs;
					if(grid.isNew){
						var sn = ele.up('tr').getAttribute('sn');
						extInputs = [];
						$$('#grid tr[sn='+sn+']').each(function(s_elem){
							<%--[20230628]修正問題1.新增繼承人資料，通訊地址並不會寫入DTDSE173  問題2.修改時日期欄位會修改失敗--%>
							extInputs = extInputs.concat( s_elem.select('input[fieldName=TEL_AREA]','input[fieldName=TEL_NUM]','input[fieldName=TEL_EXT]','input[fieldName=MOBILE]'));
							s_elem.select('input[name=INPUT_ZIPCODE]','input[name=INPUT_ADDR]','input[name=BIRTHDAY]','input[name=DEADTHDAY]').each(function(elem){
								var key = elem.name;
								if(key == 'INPUT_ZIPCODE'){
									insertRecord[index]['TOWN_CODE'] = elem.getValue();
								}else if(key == 'INPUT_ADDR'){
									insertRecord[index]['ADDR'] = elem.getValue();
								}else{
									insertRecord[index][key] = elem.getValue();
								}
							});
						});
					}else{
						extInputs = ele.up('tr').next(1).select('select[fieldName=CITY_CODE]','select[fieldName=TOWN_CODE]','input[fieldName=ADDR]','input[fieldName=CITY_CODE]','input[fieldName=TOWN_CODE]','input[fieldName=TEL_AREA]','input[fieldName=TEL_NUM]','input[fieldName=TEL_EXT]','input[fieldName=MOBILE]');
					}
					if(extInputs.length==0){
						return;
					}
					extInputs.each(function(fieldObj){
						insertRecord[index][fieldObj.readAttribute('fieldName')]=fieldObj.value;
					});
					index++;
				});
			}
			return insertRecord;
		},
		getHeirRecords: function(){
			var heirList = grid.getAllRecords();
			if(heirList.length==0){
				return heirList;
			}
			var index = 0;
			$('grid').select('tbody input[type=checkbox]').each(function(ele){
				var extInputs;
				if(grid.isNew){
					var sn = ele.up('tr').getAttribute('sn');
					extInputs = [];
					$$('#grid tr[sn='+sn+']').each(function(s_elem){
						extInputs = extInputs.concat( s_elem.select('select[fieldName=CITY_CODE]','select[fieldName=TOWN_CODE]','input[fieldName=ADDR]','input[fieldName=CITY_CODE]','input[fieldName=TOWN_CODE]','input[fieldName=TEL_AREA]','input[fieldName=TEL_NUM]','input[fieldName=TEL_EXT]','input[fieldName=MOBILE]'));
					});
				}else{
					extInputs = ele.up('tr').next(1).select('select[fieldName=CITY_CODE]','select[fieldName=TOWN_CODE]','input[fieldName=ADDR]','input[fieldName=CITY_CODE]','input[fieldName=TOWN_CODE]','input[fieldName=TEL_AREA]','input[fieldName=TEL_NUM]','input[fieldName=TEL_EXT]','input[fieldName=MOBILE]');
				}
				if(extInputs.length==0){
					return;
				}
				extInputs.each(function(fieldObj){
					heirList[index][fieldObj.readAttribute('fieldName')]=fieldObj.value;
				});
				index++;
			});
			return heirList;
		}
	};
	
	//製造tableUI中的元素
	function makeDateInput (fieldName , val , id , type, isEUDC){
		if(val){
			val = val.trim();
		}
		if(type == 'date'){
			var INPUT = new Element('input' , {datatype : 'ROCdate',name: id, fieldName : fieldName , className : 'textBox2', size : 10  ,maxlength :9  , value : val});
			INPUT.observe('change' , function(event){
				this.value = event.target.value.trim();
				var tr = this.up('tr');
				var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
				dataObj[id] = event.target.value;
			
			});
			var IMG = new Element('img' , { src : '<%=imageBase%>/CM/calendar.gif' , alt : 'Date' });
			
			IMG.observe('click' , function(event){			
				getCalendarFor(this.up('td').select('input')[0]);		
			});
			var SPAN = new Element('span');
			SPAN.insert(INPUT).insert(IMG);
			return SPAN;
		}
		if(type =='input'){
			
			var INPUT = new Element('input' , { fieldName : fieldName , className : 'textBox2', size : 12  , value : val});
			INPUT.observe('blur' , function(event){				
				var tr = this.up('tr');
				var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
				
				if(id == 'HEIR_ID'){
					event.target.value = event.target.value.toUpperCase();				
				}
				dataObj[id] = event.target.value;
			
			});	
			<%-- [20240215]難字調整 --%>	
			if(id == 'HEIR_NAME'){
				INPUT.setAttribute('alt','ch');
			}
			return INPUT;
		}
	}

	return {

			initApp : function() {
			
				<cathay:LocaleDisplay sysCode='DS' var='localeDisplay' dateFields='' />
				PageUI.createPageWithAllBodySubElement("DSE11701", "法務件", "繼承管理明細" , 1);					

				grid2 = new TableUI({
					table:$('grid2'),pageSize:10,allSortable:false,
					autoCheckBox:{
						text:'選取', 
						type:'radio',
						action:function(node, boxStatus, records ){
							if(!boxStatus) return;//檢核box狀態，避免連續點選，造成載入資料有問題
						}					
					},
					<%-- [20240215] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					column:[
						{header:"被繼承人", key:'ANCESTOR_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>
						{header:"ID", key:'ANCESTOR_ID'},
						{header:"結案原因", key:'CLOSED_REASON_NM'},
						{header:"備註", key:'CLOSED_MEMO'},
					    {header:"輸入日期" , key:'INPUT_DATE',sortRule:'datetime'},
						{header:"輸入人員", key:'INPUT_NAME', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>						
						{header:"覆核日期" , key:'CONFIRM_DATE',sortRule:'datetime'},
						{header:"覆核人員", key:'CONFIRM_NAME', attrs:{style:"font-family:'EUDC'"} }<%-- [20240215]難字調整 --%>
					]
				});
							
				//table 
				grid = new TableUI ( {
					table: $('grid'),  allSortable:false, pageSize: 10, split : ['BIRTHDAY','CITY_CODE'],
					autoCheckBox:{	
						isSelectAll : true
					},
					column: [
						{header: '狀態' , key : 'STATUS_NM' , attrs : { rowSpan : 3}},
						{header: '順位' , key : 'PRIORITY',
							 input:{                               
								type:'select' ,    
								opts : PRIORITY_Map,										
								action : function(node , dataObj , textDiv, orgData ){												
										actions.doChangeRelation(node.value);
										var tr = $(node).up('tr'); 											
										var td = tr.select('td[name = "RELATION"]')[0];	
										td.select('span')[0];
										td.update(SELECT_DOM);												
										var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
										dataObj.RELATION = SELECT_DOM.value;										
									}										
								} 
						},
						{header: '關係' , key : 'RELATION',
							render : function(rec , val){
								actions.doChangeRelation(rec.PRIORITY);		
								SELECT_DOM.value = val;		
								return SELECT_DOM;
							}
						},
						{header: '繼承情形' , key : 'HEIR_CODE',
							 /*
							 input:{                               
								type:'select' ,    
								opts : HEIR_CODE_Map,
								actionWhenStart : true,
									action : function(node , dataObj , textDiv, orgData ){	
										$(node).setAttribute('fieldName' , '繼承情形');
										$(node).value = dataObj[0].HEIR_CODE;
									    var tr = $(node).up('tr').nextSibling;
						                var COURT_CODE = tr.select("td[name=COURT_CODE] input");
									   //COURT_CODE.disable();
										
									
									}
								}
							*/
                            							
							render : function(rec , val){
							    var input1 = new Element("select");
									for(key in HEIR_CODE_Map){
										input1.add(new Option(HEIR_CODE_Map[key],key));
									}
                                    input1.value=val;						
									input1.observe('change', function(event){
									    var tr=this.up('tr').nextSibling;
										var COURT_CODE = $(tr).select('td[name =COURT_CODE] select')[0];
										var CASE_NO = $(tr).select('td[name =CASE_NO]')[0].select('input')[0];
										var HEIR_CODE=event.target.value;
										dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0]; 
										dataObj.HEIR_CODE=HEIR_CODE;
									    //if 繼承情形選擇 ‘1’ OR ‘6’ 法定繼承、繼承前死亡則法院、案號DISABLE，不可輸入

										if(HEIR_CODE=='1'||HEIR_CODE=='6'){
                                            COURT_CODE.disabled=true;
										    CASE_NO.disabled=true;
											COURT_CODE.update("");	
											CASE_NO.value="";
										}else{
										    COURT_CODE.disabled=false;
										    CASE_NO.disabled=false;
										    COURT_CODE.options.length=0;
											for(key in COURT_Map){
												COURT_CODE.add(new Option(COURT_Map[key],key));
											}
											
										}
										
										
									} );
							    return input1;
							}
							
                             							
								
						},
						{header: '姓名' , key : 'HEIR_NAME',
							render : function (rec , val){
								return makeDateInput( '姓名' , val , 'HEIR_NAME' , 'input');
							}
						},
						{header: 'ID' , key : 'HEIR_ID',
							render : function (rec , val){
								return makeDateInput( 'ID' , val , 'HEIR_ID' , 'input');									
							}
						},
						{header: '作業人員' , key : 'LST_PROC_NM', attrs:{style:"font-family:'EUDC'"} },<%-- [20240215]難字調整 --%>							
						{header: '出生日期' , key : 'BIRTHDAY',							
							render : function (rec , val){
								return makeDateInput( '出生日期' , val , 'BIRTHDAY' , 'date');
						}},
						{header: '死亡日期' , key : 'DEADTHDAY',							
							render : function (rec , val){
								return makeDateInput( '死亡日期' , val , 'DEADTHDAY' , 'date');									
							}
						},
						{header: '法院' , key : 'COURT_CODE',
							 input:{
								type:'select' ,    
								opts : COURT_Map,
								actionWhenStart : true,
									action : function(node , dataObj , textDiv, orgData ){
										$(node).setAttribute('fieldName' , '法院');
										
										$(node).value = dataObj[0].COURT_CODE;
										if(dataObj[0].HEIR_CODE==1||dataObj[0].HEIR_CODE==6){
											$(node).add(new Option("",""));
											$(node).value="";
											$(node).disable();
										}
									}
								}
						},
						{header: '案號' , key : 'CASE_NO', attrs : { colSpan : 2 },
							 input:{                               
								type:'TEXT' , size:30 , width:40 ,										
								actionWhenStart : true,
									action : function(node , dataObj , textDiv, orgData ){												
										$(node).setAttribute('fieldName' , '案號');	
										$(node).value = $(node).value.trim();
										if(dataObj[0].HEIR_CODE==1||dataObj[0].HEIR_CODE==6){
										    $(node).disable();
										}
									}		
								}    
						},
						{header: '作業日期' , key : 'LST_PROC_DATE'},
						{header: '通訊地址' , key : 'CITY_CODE', attrs : { colSpan : 3, align: 'left'}, 
							render : function( record , val){	
								var ADDR = record.ADDR;				
								var span = new Element('span');	
								var TD_ADDR = new DSZ01000(span, '1');  				
								if(ADDR){
									TD_ADDR.setINPUT_ADDR(ADDR);
									TD_ADDR.setINPUT_ZIPCODE(record.TOWN_CODE);	
								}
								var obj = TD_ADDR.getAllSelectObject();			
								obj['INPUT_ADDR'].observe('blur', function(event){
									var tr=this.up('tr');
									dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.ADDR = this.value;	
									dataObj.TOWN_CODE = TD_ADDR.getINPUT_ZIPCODE();			
								});						
								return span;
							}	  
						},
						{header: '區碼/市內電話/分機' , key : 'TEL_AREA', attrs : { colSpan : 2 }, render: function(record, v){
							return new Element('span').addClassName('gridSpan').insert(
								new Element('input', {text:'text', size:5, maxLength:4}).writeAttribute('fieldName', 'TEL_AREA').setValue(record.TEL_AREA)
							).insert(
								new Element('input', {text:'text', size:16, maxLength:15}).writeAttribute('fieldName', 'TEL_NUM').setValue(record.TEL_NUM)
							).insert(
								new Element('input', {text:'text', size:7, maxLength:6}).writeAttribute('fieldName', 'TEL_EXT').setValue(record.TEL_EXT)
							);
						}},
						{header: '行動電話' , key : 'MOBILE', render: function(record, v){
							return new Element('input', {text:'text', size:16, maxLength:15}).writeAttribute('fieldName', 'MOBILE').setValue(v);
						}}
					],
					<%-- [20240215] 難字調整 --%>
					afterLoad: function() {
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
					},
					pageChange:function(){
						<%-- [20240215] 難字調整 --%>
						if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
						$$("#grid td[name ='PRIORITY']").each(
							function(elem){	
								var selectDom = elem.select('select')[0];
								selectDom.setAttribute('fieldName' , '順位');
								var tr = elem.up('tr');
								var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
								selectDom.setAttribute ('value' , dataObj.PRIORITY);											
							}									
						);														
					}
				});
				
				initValidation();		
				
				ADDR = new DSZ01000($('ADDR'), '1');	

				//click事件
				$('btn_updateA').observe( 'click', buttons.doUpdate);	
				$('btn_back').observe( 'click', buttons.doBack);
				$('btn_insert').observe( 'click', buttons.doInsert);	
				$('btn_update_under').observe( 'click', buttons.doUnderUpadte);
				$('btn_deleteA').observe( 'click', buttons.doDeleteA);
				$('btn_delete').observe( 'click', buttons.doDelete);	
				$('btn_confirm').observe( 'click', buttons.doConfirm);	
				$('btn_cancelconfirm').observe( 'click', buttons.doCancelConfirm);	
				$('btn_print').observe( 'click', buttons.doPrint);				
				$('btn_add_person').observe( 'click', buttons.doAddPerson);	
				
				$('btn_close_insert').observe( 'click', buttons.doCloseInsert);	
				$('btn_close_delete').observe( 'click', buttons.doCloseDelete);	
				$('btn_close_confirm').observe( 'click', buttons.doCloseConfirm);	
				$('btn_close_cancelconfirm').observe( 'click', buttons.doCloseCancelConfirm);

				fix();

				displayMessage();	
				
				

				buttonAuth();

				buttons.doQuery();	
			}
	};

};

</script>
</head>
<body>		
	<form id="form" name="form" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "tableA" width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center" class = "tbYellow0" colspan = "7">
					<b>被繼承人</b>
				</td>
			</tr>
			<tr>
				<td align="center" colspan="7">
					<input id="btn_updateA" type="button" class="button" value="修改" disabled />
					<input id="btn_deleteA" type="button" class="button" value="刪除" />
					<input id="btn_back"    type="button" class="button" value="上一頁" />
				</td>
			</tr>
			<tr>
				<td class = "tbBlue" align = "center">
					<b>被繼承人	</b>
				</td>
				<td class = "tbBlue" align = "center">
					<b>ID</b>	
				</td>
				<td class = "tbBlue" align = "center">
					<b>出生年月日</b>	
				</td>
				<td class = "tbBlue" align = "center">
					<b>死亡日期</b>	
				</td>
				<td class = "tbBlue" align = "center">
					<b>死亡時戶籍地	</b>
				</td>
				<td class = "tbBlue" align = "center">
					<b>作業人員</b>	
				</td>
				<td class = "tbBlue" align = "center">
					<b>作業日期</b>	
				</td>
			</tr>
			
			<!--資料顯示 -->
			<tr>
				<td class = "tbYellow" align = "center">
					<span id = "ANCESTOR_NAME" style="font-family:'EUDC'"> </span><%-- [20240215]難字調整 --%>
				</td>
				<td class = "tbYellow"  align = "center">
					<span id = "ANCESTOR_ID"> </span>
				</td>
				
				<td class = "tbYellow"  align = "center">
                   <input name="BIRTHDAY_2" id="BIRTHDAY_2" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate-Before-Bir" size="10" maxlength="9" fieldName = "出生日期"/>
                   <img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('BIRTHDAY_2'))" />    
                   <input type = "hidden" id = "BIRTHDAY"/>
               </td>
               <td class = "tbYellow" align = "center">
                   <input name="DEADTHDAY" id="DEADTHDAY" datatype="ROCdate" type="text" class="textBox2 validate-ROCDate-Before-Dead" size="10" maxlength="9" fieldName = "死亡日期"/>
                   <img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('DEADTHDAY'))" />    
               </td>
               
					<td class="tbYellow" id ="ADDR" >				
				
				<td class = "tbYellow" align = "center">
					<span id = "LST_PROC_NM" style="font-family:'EUDC'"> </span><%-- [20240215]難字調整 --%>
				</td>
				<td class = "tbYellow" align = "center">
					<span id = "LST_PROC_DATE"> </span>
				</td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center" class = "tbYellow0" colspan = "7">
					<b>被繼承人結案</b>
				</td>
			</tr>
			<tr>
				<td class="tbYellow" width="10%"  >
					結案原因
				</td>
				<td class="tbYellow2" width="90%">			
					<select id="CLOSED_REASON" name="CLOSED_REASON">		
						<option value="">請選擇</option>					
						<c:forEach items="${CLOSED_REASON_LIST}" var="CLOSED_REASON_LIST">
							<option value="${CLOSED_REASON_LIST.key}" />
								${CLOSED_REASON_LIST.value}
							</option>	
						</c:forEach>
				    </select>
					<input id="CLOSED_MEMO" name="CLOSED_MEMO" type="text" class="textBox2" size='27' maxlength="50" value=""/>				
					<input id = "btn_close_insert" type = "button" class = "button" value = "新增"   />											
					<input id = "btn_close_delete" type = "button" class = "button" value = "刪除"   />	
					<input id = "btn_close_confirm" type = "button" class = "button" value = "覆核"   />	
					<input id = "btn_close_cancelconfirm" type = "button" class = "button" value = "取消覆核"   />							
				</td>							
			</tr>		
		</table>		
		<table id = "grid2" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center" class = "tbYellow0">
					<b>繼承人</b>
				</td>
			</tr>
			<tr>
				<td align = "center">
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />						
					<input id = "btn_update_under" type = "button" class = "button" value = "修改"   />						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"   />	
					<input id = "btn_confirm" type = "button" class = "button" value = "覆核"   />	
					<input id = "btn_cancelconfirm" type = "button" class = "button" value = "取消覆核"   />	
					<input id = "btn_print" type = "button" class = "button" value = "製表"   />	
				</td>				
			</tr>		
		</table>
	</form>	
	<form id="form1" name="form1" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<table id = "grid" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td align = "center" class = "tbBlue2">
					<input id = "btn_add_person" type = "button" class = "button" value = "新增繼承人"   />	
				</td>
			</tr>	
		</table>
	</form>	
</body>
</html>