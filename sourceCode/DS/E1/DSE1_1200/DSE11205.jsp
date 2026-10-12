<%@ page language="java" contentType="text/html; charset=BIG5"%>
<%@ taglib prefix="dz" tagdir="/WEB-INF/tags/csr/dz"%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">


<!--
程式：DSE11205.jsp
功能：調查財產作業
作者：徐麗雲
完成：2013/06/20

[20240207]
難字調整
高強禾
 -->

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=big5" />
<%@ include file="/html/CM/header.jsp"%>
<%@ include file="/html/CM/msgDisplayer.jsp"%><!--顯示接收到的錯誤訊息-->
<fmt:setBundle basename="TextResource" /><!--匯入外部Javascript 與 css-->
<title></title>

<link href="<%=cssBase%>/cm.css" rel="stylesheet" type="text/css" />
<script type='text/javascript' src='<%=htmlBase%>/CM/js/prototype.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ajax/CSRUtil.js"></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/PageUI.js'></script>
<script type='text/javascript' src='<%=htmlBase%>/CM/js/ui/TableUI.js'></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/validation.js"></script>
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/calendar.js"></script> 
<script type="text/JavaScript" src="<%=htmlBase%>/CM/js/date.js"></script>
<script type="text/javascript" src="<%=htmlBase%>/CM/js/ui/popupWin.js"></script>
<%-- [20240207] 難字調整 --%>
<style type="text/css">
@font-face {
	font-family: 'EUDC';
	src: url("/DSWeb/hanLinks/eudc.woff") format("woff"),
		url("/DSWeb/hanLinks/eudc.ttf") format("truetype");
	font-weight: normal;
	font-style: normal
}
</style>
<script type="text/javascript">


Event.observe(window, 'load', new DSE11205().initApp);
Event.observe(window, 'resize', fix);
Event.observe(window, 'scroll', fix);

function DSE11205(){
	
	var valid1; //畫面檢核物件	
	var LOAN_ID = '${LOAN_ID}';//貸款帳號
	var REFER_ID = '${REFER_ID}';//原貸帳號
	var PROEPRTY_TYPE_List;//種類下拉選單
	var PROEPRTY_ITEM1_List;//項目下拉選單--財產
	var PROEPRTY_ITEM2_List;//項目下拉選單--所得
	var OPPOSITE_List;//相對人下拉選單
	var grid;	
	var grid1;
	var oriList=[];
	var index = 0;
	var checkedList = [];
	
	function initValidation(){
		//檢核
		Validation.addAllThese([
			[ 'checkID',  '身份證字號/統一編號格式錯誤',
				function(v){  
					return Validation.get('IsEmpty').test(v) || validation.checkROCID( v ) || validation.checkUniSN( v ); //2018-07-17統一編號也要能輸入，故增加統一編號檢核
				}
			]
			
		]);
		
		valid1 = new Validation("form1", { focusOnError:true, immediate:false, mode : 'validator'});
		valid1.define( "required" , { id: "OTHER_ID"  } );
		valid1.define( "checkID" , { id: "OTHER_ID"  } );
		valid1.define( "required" , { id: "OTHER_NAME"  } );		
		
		
	}
	
	//按鈕授權
	function buttonAuth() {
		var authButtons = { 
			B0003 : 'btn_insert' ,
			B0004 : 'btn_update',
			B0005 : 'btn_delete',
			B0235 : 'btn_query_scan'		
		};
		<dz:grantButtons FUNC_ID ="DSE11205"/>
	}
	
	var ajaxRequest = new CSRUtil.AjaxHandler.request('<%=dispatcher%>/DSE1_1205/');
	
	//共用的Ajax
	function ajaxPost ( actionName, params, successFunction, errorFunction){	
		ajaxRequest.post( actionName, params, successFunction , errorFunction);
	
	}		
	
	
	//各種action
	var actions = {
		
		//當「相對人」下拉選單為「其他」時為輸入欄位，否則為隱藏欄位
		genOtherCols : function(){
			if($('OPPOSITE_ID1').value == '0'){
				$('OTHERS').show();	
			}else{
				$('OTHERS').hide();	
			}
		},
		
		//將選取資料放入區塊A與區塊B
		showGridData : function(record){
						
			//將資料放入A區塊
			$('INVESTIGATE_DATE').value = toROC(record.INVESTIGATE_DATE) || '';
				
			//檢查ID是否在相對人下拉選單內									
			var isOther = true;	
			for(var i = 0 ; i < OPPOSITE_List.length ; i++){
				if(record.OPPOSITE_ID1 == OPPOSITE_List[i].ID){
					isOther = false;
					break;
				}
			}
			
			if(isOther){//ID不存在於下拉選單中
				$('OTHERS').show();
				$('OPPOSITE_ID1').value = '0';
				$('OTHER_ID').value = record.OPPOSITE_ID1;
				$('OTHER_NAME').value = record.OPPOSITE_NAME1;
			}else{
				$('OPPOSITE_ID1').value = record.OPPOSITE_ID1;
				$('OTHER_ID').value = '';
				$('OTHER_NAME').value = '';
				$('OTHERS').hide();
			}
			
			$w('YEAR_INCOME TOTAL_WEALTH').each(
				function(ele){						
					$(ele).innerHTML = record[ele] ? CSRUtil.$fmt(record[ele], "#,###") : 0;
				}			
			);
		 
			//將資料放入B區塊 
			var Detail_List = record.Detail_List;
		
			//產生一個物件 Temp , 用來load grid , 因為這樣才不會因為沒copy物件 而改到原始的物件內容
			var tempList = new Object([]);
			oriList = [];//清空
			index = 0;
			
			//如果List內有資料 , 就將資料一個copy到各List中
			if(Detail_List.length > 0){
				for(var i = 0 ; i < Detail_List.length ; i ++){
					var temp_vo = Detail_List[i];
					temp_vo.index = ++index;
					tempList.push(Object.clone(temp_vo));
					oriList.push(Object.clone(temp_vo));
				}	
			}else{
				//如果沒資料, 就新增一筆其他可以給user新增
				tempList.push(
					{ 	LOAN_ID : LOAN_ID,
						CASE_KIND : record.CASE_KIND, 
						SEQ_NO : record.SEQ_NO ,
						PROEPRTY_TYPE : '', 
						PROEPRTY_ITEM : '', 
						PROEPRTY_VALUE : '',
						THIRD_NAME : '',
						IS_BENEFIT : '',
						NO_BENEFIT_REASON :''
					}
				);
			}
			
			//載入list
			grid.load(tempList);
			
		},
		
		//重新計算B區年所得與財產總值
		reCalculate : function(){
			
			var tempYEAR_INCOME = 0;
			var tempTOTAL_WEALTH = 0;			
			var DTDSE104_volist = grid.getAllRecords();
			for(var i=0; i<DTDSE104_volist.length; i++){
				var tmp_vo = DTDSE104_volist[i];
				var PROEPRTY_VALUE = tmp_vo.PROEPRTY_VALUE || 0;
				if( tmp_vo.PROEPRTY_TYPE == '1' ){//財產
					tempTOTAL_WEALTH = tempTOTAL_WEALTH*1 + PROEPRTY_VALUE*1;
				}
				if(tmp_vo.PROEPRTY_TYPE == '2'){//所得					
					tempYEAR_INCOME = tempYEAR_INCOME*1 + PROEPRTY_VALUE*1;
				}
			}
			
			//更新畫面
			$('YEAR_INCOME').innerHTML = CSRUtil.$fmt(tempYEAR_INCOME, "#,###");
			$('TOTAL_WEALTH').innerHTML = CSRUtil.$fmt(tempTOTAL_WEALTH, "#,###");
		},
		
		//取得相對人姓名
		getName : function(id){
			for(var i = 0; i< OPPOSITE_List.length; i++){
				if( id == OPPOSITE_List[i].ID){
					return OPPOSITE_List[i].NAME;
				}
			}
		},
		
		//初始
		clearData : function(){
			$w('INVESTIGATE_DATE OPPOSITE_ID1 OTHER_ID OTHER_NAME').each(
				function(id){						
					$(id).value = '';
				}
			);
			$('YEAR_INCOME').innerHTML = '';
			$('TOTAL_WEALTH').innerHTML = '';
			$('OTHERS').hide();
		}
		,initGridData:function(){
			var iniinsertMap = [{ 

				LOAN_ID: LOAN_ID,
				index : index + 1 , 
				PROEPRTY_TYPE : '1' , 
				PROEPRTY_ITEM : '01' ,
				PROEPRTY_VALUE : '',
				THIRD_NAME :'',
				IS_BENEFIT:'',
				NO_BENEFIT_REASON :''
			}]
			grid.load(iniinsertMap)
		},
		
		//超連結1
		POP_UP1 :function(event){

			var strlink;			
			
			strlink='/AVWeb/servlet/HttpDispatcher/AVE0_6000/query';
			
			popupWin.windowOpen(strlink,{
				parameters : { 
				    'IMG_KIND_OPT'	: 'DS01',    //文件代碼
					'LINK_TYPE' : 'Y',
					'RCPT_NO' : REFER_ID       //原貸帳號
					
				}
			});
		}
	};
		
		
	//按鈕功能	
	var buttons = {
		
		//初始查詢
		doQuery : function(){		
			ajaxPost( 'query' , { LOAN_ID : LOAN_ID},
				function(resp){						
					PROEPRTY_TYPE_List = resp.PROEPRTY_TYPE_List;
					PROEPRTY_ITEM1_List = resp.PROEPRTY_ITEM1_List;
					PROEPRTY_ITEM2_List = resp.PROEPRTY_ITEM2_List;
					OPPOSITE_List = resp.OPPOSITE_List;
					//將下拉選單內容加到頁面
					for(var i = 0; i< OPPOSITE_List.length; i++){
						$('OPPOSITE_ID1').add(new Option(OPPOSITE_List[i].NAME, OPPOSITE_List[i].ID));
					}
					$('OPPOSITE_ID1').add(new Option('其他', '0'));
					actions.initGridData();
					//grid.load([]);
					grid1.load(resp.rtnList || []);
				},
				function(resp){
					PROEPRTY_TYPE_List = resp.PROEPRTY_TYPE_List;
					PROEPRTY_ITEM1_List = resp.PROEPRTY_ITEM1_List;
					PROEPRTY_ITEM2_List = resp.PROEPRTY_ITEM2_List;
					OPPOSITE_List = resp.OPPOSITE_List;
					oriList = [];
					for(var i = 0; i< OPPOSITE_List.length; i++){
						$('OPPOSITE_ID1').add(new Option(OPPOSITE_List[i].NAME, OPPOSITE_List[i].ID));
					}
					$('OPPOSITE_ID1').add(new Option('其他', '0'));
					actions.initGridData();
					//grid.load([]);					
					grid1.load([]);	
				}
			);

		},
	
		
		//新增
		doInsert : function(){
			
			valid1.reset();	
			var DTDSE104_voList = grid.getAllRecords();			

			if(DTDSE104_voList.length == 0){
				alert('請輸入財產明細資料!');
				return;
			}
					
			if(!valid1.validate()){
				return;
			}
			
			//重新計算
			actions.reCalculate();
			
			var ori_E105vo = grid1.getCheckedRecord()[0] || {};
			//取得畫面(A區)資料
			var DTDSE105_vo = {};
			DTDSE105_vo.LOAN_ID = LOAN_ID;
			DTDSE105_vo.CASE_KIND = ori_E105vo.CASE_KIND;
			DTDSE105_vo.SEQ_NO = ori_E105vo.SEQ_NO;
			DTDSE105_vo.INVESTIGATE_DATE = $F('INVESTIGATE_DATE');
			DTDSE105_vo.YEAR_INCOME = $('YEAR_INCOME').innerHTML.replace(/,/g,'');
			DTDSE105_vo.TOTAL_WEALTH = $('TOTAL_WEALTH').innerHTML.replace(/,/g,'');
			var the_ID = $F('OPPOSITE_ID1');
			if(the_ID =='0'){
				DTDSE105_vo.OPPOSITE_ID1 = $F('OTHER_ID');
				DTDSE105_vo.OPPOSITE_NAME1 = $F('OTHER_NAME');
			}else{
				DTDSE105_vo.OPPOSITE_ID1 = the_ID;
				DTDSE105_vo.OPPOSITE_NAME1 = actions.getName(the_ID);
			}
				
			//發送ajax
			ajaxPost( 'insert' , {
					LOAN_ID : LOAN_ID,
					DTDSE105_vo : Object.toJSON(DTDSE105_vo),
					DTDSE104_voList : Object.toJSON(DTDSE104_voList)
				},
				
				function(resp){					
					grid1.load(resp.rtnList || []);
					grid.load([]);
					actions.clearData();
				}				
			);
		},
		
		//修改
		doUpdate : function(action){
			
			valid1.reset();			
		
			var updateList = grid1.getCheckedRecord();			
			if( updateList.length == 0 ){
				alert('請選擇要修改資料!');
				return;
			}
			
			var DTDSE104_voList = grid.getAllRecords();
			if(DTDSE104_voList.length == 0){
				alert('請輸入財產明細資料!');
				return;
			}
			
			if(!valid1.validate()){
				return;
			}
			//重新計算
			actions.reCalculate();
			
			var DTDSE105_vo  = updateList[0];			
			//將畫面資料取代
			DTDSE105_vo.LOAN_ID = LOAN_ID;
			DTDSE105_vo.INVESTIGATE_DATE = $F('INVESTIGATE_DATE');
			DTDSE105_vo.YEAR_INCOME = $('YEAR_INCOME').innerHTML.replace(/,/g,'');
			DTDSE105_vo.TOTAL_WEALTH = $('TOTAL_WEALTH').innerHTML.replace(/,/g,'');
			var the_ID = $F('OPPOSITE_ID1');
			if( the_ID == '0'){
				DTDSE105_vo.OPPOSITE_ID1 = $F('OTHER_ID');
				DTDSE105_vo.OPPOSITE_NAME1 = $F('OTHER_NAME');
			}else{
				DTDSE105_vo.OPPOSITE_ID1 = the_ID;
				DTDSE105_vo.OPPOSITE_NAME1 = actions.getName(the_ID);
			}
			
			//發送ajax
			ajaxPost( 'update' , {
					LOAN_ID : LOAN_ID,
					DTDSE105_vo : Object.toJSON(DTDSE105_vo),
					DTDSE104_voList : Object.toJSON(DTDSE104_voList)
				},
				function(resp){					
					grid1.load(resp.rtnList || []);	
					grid.load([]);
					actions.clearData();					
				}				
			);		
			
		},
		
		//刪除
		doDelete : function(action){
		
			var delList = grid1.getCheckedRecord();			
			if( delList.length == 0 ){
				alert('請選擇欲刪除資料!');
				return;			
			}
			
			if(!confirm('是否確認刪除?')){
				return;			
			}
			
			var DTDSE105_vo = delList[0];
		
			//發送ajax
			ajaxPost( 'delete' , {LOAN_ID : LOAN_ID , DTDSE105_vo : Object.toJSON(DTDSE105_vo)},
				function(resp){	
					grid1.load(resp.rtnList || []);	
					grid.load([]);
					actions.clearData();
				}				
			);	
			
		},
		
		//新增財產
		doInsertAsset : function(event){		
			valid1.reset();			
			//var choseRec = grid.getCheckedRecord();
			var DTDSE104_voList = grid.getAllRecords();
			
			var map=DTDSE104_voList[0];
			var tmpMap = Object.clone(map);
			tmpMap.LOAN_ID=LOAN_ID;
			tmpMap.index = index + 1;
			tmpMap.PROEPRTY_TYPE ='1';
			tmpMap.PROEPRTY_ITEM ='01';
			tmpMap.PROEPRTY_VALUE ='';
			tmpMap.THIRD_NAME ='';
			tmpMap.IS_BENEFIT ='';
			tmpMap.NO_BENEFIT_REASON ='';
			DTDSE104_voList.push(tmpMap);
			grid.load(DTDSE104_voList);
			//序號+1
			index++;
			actions.reCalculate();
			/*if( choseRec.length == 0  ){
				alert('請先選擇一筆要新增的資料!');
				return;
			}
		    var DTDSE104_vo = choseRec[0];
			DTDSE104_vo.index = index + 1;
			var DTDSE104_voList = [];			
			for(var i=0; i < oriList.length; i++){
				var tmp_vo = oriList[i];
				DTDSE104_voList.push(Object.clone(tmp_vo));
			}
			
			//新增一筆資料
			DTDSE104_voList.push(Object.clone(DTDSE104_vo));
			oriList.push(Object.clone(DTDSE104_vo));
			grid.load(DTDSE104_voList);		
			
			//序號+1
			index++;
			actions.reCalculate();
			alert('調查財產明細資料有變更，請於財產明細資料輸入完畢後，請按下新增或修改按鈕');*/		
		},		
		
		//移除財產
		doDeleteAsset : function(event){
			
			valid1.reset();			
			var choseRec = grid.getCheckedRecord();
			if( choseRec.length == 0  ){
				alert('請選取一筆資料!');
				return;
			}
			
			var DTDSE104_vo = choseRec[0];
			var DTDSE104_voList = grid.getAllRecords();		
					
			for ( var i = 0 ; i < DTDSE104_voList.length ; i++){
				var temp_vo = DTDSE104_voList[i];
					if( temp_vo.index == DTDSE104_vo.index ) {
						oriList.splice( i,1);
						if(DTDSE104_voList.length == 1){
							//一筆資料的處理，清空欄位
							DTDSE104_voList[i].PROEPRTY_TYPE ='';
							DTDSE104_voList[i].PROEPRTY_ITEM ='';
							DTDSE104_voList[i].PROEPRTY_VALUE ='';
							DTDSE104_voList[i].THIRD_NAME ='';
							DTDSE104_voList[i].IS_BENEFIT ='';
							DTDSE104_voList[i].NO_BENEFIT_REASON ='';
						}else{
							//移除資料
							DTDSE104_voList.splice(i,1);
						}
						
						break;
					}
			}

			grid.load(DTDSE104_voList);
			actions.reCalculate();
			alert('調查財產明細資料有變更，請於財產明細資料輸入完畢後，按下新增或修改按鈕');			
		}
		
	};
	

	return{
	
		initApp : function(){
		
			PageUI.createPageWithAllBodySubElement('DSE11205','法務作業','調查財產作業',1,true);
			
			//產生 Grid 物件	
			grid = new TableUI (
				{ table: $('grid'), pageSize: 10, 
				  allSortable:false, 
				  autoCheckBox :{ type :'radio'},
				  overDiv:false,
				  afterLoad: function(ele){
					for(var i=0; i<checkedList.length; i++){
						checkedList[i].checked = true;
					}
					checkedList = [];
					autoFormatToNumber();	
				  },
				  <%-- [20240207] 難字調整 --%>
				  afterLoad: function() {
					  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				  },
				  pageChange: function() {
					  if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				  },
			  	  column : [
					{header : '種類', key : 'PROEPRTY_TYPE'
						,render : function(record, value){
							var select = new Element('select' , {className : 'textBox2 required' , fieldName : '種類'});							
							//加入種類下拉選單
							for (key in PROEPRTY_TYPE_List){
								select.add(new Option(PROEPRTY_TYPE_List[key], key));
							}
							
							//如果改下拉選單
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.PROEPRTY_TYPE = event.target.value;
									
									var PROEPRTY_ITEM_List;
									//加入種類下拉選單
									if(dataObj.PROEPRTY_TYPE=='1'){
										PROEPRTY_ITEM_List=PROEPRTY_ITEM1_List;
									}else{
										PROEPRTY_ITEM_List=PROEPRTY_ITEM2_List;
									}
									var PROEPRTY_ITEM_SELECT=tr.select("td[name=PROEPRTY_ITEM] select")[0];
									PROEPRTY_ITEM_SELECT.length=0;
									for (key in PROEPRTY_ITEM_List){
										PROEPRTY_ITEM_SELECT.add(new Option(PROEPRTY_ITEM_List[key], key));
									}

									actions.reCalculate();
								}
							);
							
							//預設值
							select.value = value;
							return select;						
		
						}
					},
					{header: '項目/金額' , key : 'PROEPRTY_ITEM'
						,render : function(record, value){
							var td = new Element('td');
							var select = new Element('select' , {className : 'textBox2' , fieldName : '項目'});
							var PROEPRTY_ITEM_List;
                            
							if(record.PROEPRTY_TYPE=='2'){
								PROEPRTY_ITEM_List=PROEPRTY_ITEM2_List;
							}else{
								PROEPRTY_ITEM_List=PROEPRTY_ITEM1_List;
							}
						
							for (key in PROEPRTY_ITEM_List){
								select.add(new Option(PROEPRTY_ITEM_List[key], key));
							}
							select.value = value;
							
							//如果改下拉選單
							select.observe('change' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.PROEPRTY_ITEM = event.target.value;												
								}
							);
							
							var PROEPRTY_VALUE_id =  'PROEPRTY_VALUE_id_' + index;
							var input = new Element('input' , {id: PROEPRTY_VALUE_id , className : 'textBox2' , type:'text' , datatype:'number', pattern : '#,###', size : '15' , maxLength : '14' ,fieldName : '項目金額'});
							input.value = record.PROEPRTY_VALUE ? CSRUtil.$fmt(record.PROEPRTY_VALUE,'#,###') : '';
							
							//如果異動欄位值
							input.observe('blur' , function(event){						
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									var new_value = event.target.value;
									dataObj.PROEPRTY_VALUE = new_value.replace(/,/g,'');
									actions.reCalculate();
								}
							);
							
							td.insert(select).insert('&nbsp&nbsp').insert(input);
							return td;								
						}
					},
					<%-- [20240207] 難字調整：第三人 --%>
					{header: '第三人' , key : 'THIRD_NAME'
						,render : function(record, value){
							var input = new Element('input' , {className : 'textBox2', type:'text', size : '15' , maxLength : '30' ,fieldName : '第三人', alt:'ch'});
							input.value = value;
							input.observe('blur' , function(event){						
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.THIRD_NAME = event.target.value;
								}
							);
							return input;
						}
					},
					{header: '有實益' , key : 'IS_BENEFIT'
						,render : function(record, value){
							var thechk = new Element('input', {className : 'textBox2', type : 'checkbox', value : value});
							if('1' == value){
								checkedList.push(thechk);
							}
							thechk.observe('click' , function(event){
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									if(thechk.checked){
										dataObj.IS_BENEFIT = '1';
									}else{
										dataObj.IS_BENEFIT = '0';
									}
								}
							);
							return thechk;
						}
					},
					{header: '備註' , key : 'NO_BENEFIT_REASON'
						,render : function(record, value){
							var input = new Element('input' , {className : 'textBox2', type:'text', size : '15' , maxLength : '20' ,fieldName : '備註'});
							input.value = value;
							input.observe('blur' , function(event){						
									var tr = this.up('tr');
									var dataObj = tr.dataObj || grid.getRecordsBySerialNo(tr.getAttribute("sn"))[0];
									dataObj.NO_BENEFIT_REASON = event.target.value;
								}
							);
							return input;
						}
					}
				]
			});
						
						
			//產生 Grid1 物件	
			grid1 = new TableUI ( 
				{ table: $('grid1'), pageSize: 20, allSortable:false, overDiv:false, 
					autoCheckBox :{
						type :'radio',
						action: function(checkbox , boxStatus , records) {
							//將資料帶入區塊A&B
							actions.showGridData(records[0]);
						}						
					},
				<%-- [20240207] 難字調整 --%>
				afterLoad: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				pageChange: function() {
					if ( "function" === typeof(parseEUDC) ) { parseEUDC("ap"); }
				},
				column : [
					{header: '序號' , key : 'SEQ_NO', groupKey : ['SEQ_NO']},
					{header: '查調日期' , key : 'INVESTIGATE_DATE', groupKey : ['SEQ_NO']
						,render : function(record, value){
							return Date.toInputROC( value || '' ,'/');
						}
					},
					<%-- [20240207] 難字調整：相對人 --%>
					{header: '相對人' , key : 'OPPOSITE_NAME1', groupKey : ['SEQ_NO'], attrs:{ style:"font-family:'EUDC'" }},
					{header: '種類' , key : 'PROEPRTY_TYPE_NM'},
					{header: '項目', key : 'PROEPRTY_ITEM_NM'},
					{header: '金額' , key : 'PROEPRTY_VALUE', attrs:{align:'right'}
						,render : function(record, value){
							return value ? CSRUtil.$fmt(value,'#,###') : '0';
						}
					},				
					<%-- [20240207] 難字調整：第三人 --%>
					{header: '第三人' , key : 'THIRD_NAME', attrs:{ style:"font-family:'EUDC'" }},
					{header: '實益' , key : 'IS_BENEFIT_NM'},
					{header: '備註' , key : 'NO_BENEFIT_REASON'}
				]
			});						
						
							
			//按鈕事件監聽
			$('btn_insert').observe('click', buttons.doInsert); //新增
			$('btn_update').observe('click', buttons.doUpdate); //修改
			$('btn_delete').observe('click', buttons.doDelete); //刪除
			$('btn_insert_asset').observe( 'click', buttons.doInsertAsset);//新增財產
			$('btn_delete_asset').observe( 'click', buttons.doDeleteAsset);//移除財產
			$('OPPOSITE_ID1').observe( 'change', actions.genOtherCols);//相對人選單連動
			$('OTHER_ID').observe('change',function(){//自動轉大寫
				$('OTHER_ID').value = $F('OTHER_ID').toUpperCase();
			});	
			
			$('btn_query_scan').observe('click', function(event){actions.POP_UP1(event)}); 	
			
			initValidation();//畫面日期檢核

			$('OTHERS').hide();	
			
			buttonAuth();//按鈕授權
			ajaxRequest.closeSuccMsg();
			buttons.doQuery();//初始查詢
		
			PageUI.resize();

			displayMessage();
						
		}
	}
}
</script>
</head>

<body>
<form id="form1" method="post" style="PADDING-RIGHT: 0px; PADDING-LEFT: 0px; PADDING-BOTTOM: 0px; MARGIN: 0px; PADDING-TOP: 0px">
		<div align = "center">
			<tr>
				<td>
					<input id = "btn_insert" type = "button" class = "button" value = "新增"   />						
					<input id = "btn_update" type = "button" class = "button" value = "修改"   />						
					<input id = "btn_delete" type = "button" class = "button" value = "刪除"   />
				</td>
			</tr>
		</div>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">
			<tr>
				<td class="tbYellow" width="8%" align="left" >
					查調日期
				</td>
				<td class="tbYellow2" width="12%">
					<input id="INVESTIGATE_DATE" datatype="ROCdate" type="text" class="textBox2 required validate-ROCDate" size="10" maxlength="7" fieldName = "查調日期"/>
					<img src="<%=imageBase%>/CM/calendar.gif" alt="Date" onclick="getCalendarFor($('INVESTIGATE_DATE'))" /></td>		
				<td class="tbYellow" width="8%" align="left" >
					相對人
				</td>
				<td class="tbYellow2" width="22%">
					<%-- [20240207] 難字調整：相對人 --%>
					<select id="OPPOSITE_ID1" class="textBox2 required" fieldName = "相對人" alt="ch">
						<option value="">請選擇</option>
					</select>
					<div id="OTHERS">
						ID:<input id="OTHER_ID"  type="text" class="textBox2" size="12" maxlength="10" fieldName = "相對人ID"/>
						<%-- [20240207] 難字調整：姓名 --%>
						姓名:<input id="OTHER_NAME"  type="text" class="textBox2" size="12" maxlength="30" fieldName = "相對人姓名" alt="ch" />
					</div>
				</td>	
				<td class="tbYellow" width="8%" align="left" >
					年所得
				</td>
				<td class="tbYellow2" width="12%">
					<span id="YEAR_INCOME"></span>
				</td>
				<td class="tbYellow" width="8%" align="left" >
					財產總值
				</td>
				<td class="tbYellow2" width="12%">
					<span id="TOTAL_WEALTH"></span>
				</td>
			</tr>			
		</table>
		<table id = "grid" ></table>
		<table width="100%" border="0" cellpadding="0" cellspacing="1" class="tbBox2">		
			<tr>
				<td class="tbBlue2" align = "center">
					<input id = "btn_insert_asset" type = "button" class = "button" value = "新增財產所得"/>
					<input id = "btn_delete_asset" type = "button" class = "button" value = "移除財產所得"/>
					<input id = "btn_query_scan" type = "button" class = "button" value = "財所影像檔"/>
				</td>
			</tr>			
		</table>	
		<table id = "grid1"></table>		
</form>	
</body>
</html>